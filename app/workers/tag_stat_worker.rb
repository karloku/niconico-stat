class TagStatWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'niconiconi_stat', retry: true

  ATTRS = 
    {
      l: 'length',
      h: 'size_high',
      w: 'size_low',
      e: 'view_counter',
      c: 'comment_counter',
      y: 'mylist_counter'
    }


  def perform(tag_name)
    t = Tag.find_by(name: tag_name)
    calculated = Video.where(tag_ids: t.id).map_reduce(map, reduce).out(inline: 1).finalize(finalize).first
    ATTRS.each do |key, value|
      result = calculated["value"][key.to_s]
      t.update_attributes!(
        :"a#{key}" => result["avg"],
        :"x#{key}" => result["max"],
        :"m#{key}" => result["min"],
        :"v#{key}" => result["variance"],
        :tv => result["count"]
        )
    end
  end

  def map
    attr_emits = ATTRS.map do |key, value|
      %{
        #{key}:
          {
            sum: this.#{key},
            min: this.#{key},
            max: this.#{key},
            count: 1, 
            diff: 0
          }}
    end
    emit_values = "1, {#{attr_emits.join(",")}}"
    map_function = %Q{
      function map() {
        emit(#{emit_values})
      };
    }
  end

  def reduce
    attr_reduces = ATTRS.map do |key, value|
      %{
        // temp helpers
        var delta = a.#{key}.sum/a.#{key}.count - b.#{key}.sum/b.#{key}.count; // a.#{key}.mean - b.#{key}.mean
        var weight = (a.#{key}.count * b.#{key}.count)/(a.#{key}.count + b.#{key}.count);
        
        // do the reducing
        a.#{key}.diff += b.#{key}.diff + delta*delta*weight;
        a.#{key}.sum += b.#{key}.sum;
        a.#{key}.count += b.#{key}.count;
        a.#{key}.min = Math.min(a.#{key}.min, b.#{key}.min);
        a.#{key}.max = Math.max(a.#{key}.max, b.#{key}.max);
      }
    end
    reduce_function = %{
      function reduce(key, values) {
        var a = values[0]; // will reduce into here
        for (var i=1/*!*/; i < values.length; i++){
          var b = values[i]; // will merge 'b' into 'a'

          #{attr_reduces.join("\n")}
        }
     
        return a;
      }
    }
  end

  def finalize
    attr_finalizes = ATTRS.map do |key, value|
      %Q{
        value.#{key}.avg = value.#{key}.sum / value.#{key}.count;
        value.#{key}.variance = value.#{key}.diff / value.#{key}.count;
        value.#{key}.stddev = Math.sqrt(value.#{key}.variance);
      }
    end
    finalize_function = %{
      function finalize(key, value){ 
        #{attr_finalizes.join("\n")}
        return value;
      }
    }
  end
end
