module ChronoTrigger
  class Trigger
    
    attr_accessor :name
    
    def initialize(name)
      self.name = name
    end
    
    #Define the code to be run when the cron job is ready to be executed.
    def runs(&block)
      @exec_block = block
    end
    
    #Specify what days the task should run on.
    #Values are :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
    def on(*days)
      cron_entry.set_days(days)
    end
    
    #Specify what calendar day the task should run on; think monthly jobs.
    #Values are 1-31
    def monthly_on(*calendar_day)
      cron_entry.set_calendar_days(calendar_day)
    end
    
    #Specify what hours and minutes the task should run at 
    #(e.g. :minute=>10, :hour=>3 or :minute=>[10,20,30], :hour=>[1,2,3])
    def at(options={})
      validate_hours_or_minutes!(options)
      
      if hour = (options[:hour] || options[:hours])
        cron_entry.set_hours(hour)
      end
      
      if minute = (options[:minute] || options[:minutes])
        cron_entry.set_minutes(minute)
      end
    end
    
    #Specify a repeating interval of hours and minutes to run.
    #Specifying minutes not divisible by 60 result in an exception, use #at instead.
    def every(options={})
      validate_hours_or_minutes!(options)
      if minutes = (options[:minutes] || options[:minute])
        cron_entry.set_minutes(extract_minutes_for_every(minutes))
      end
      
      if hours = (options[:hours] || options[:hour])
        cron_entry.set_hours(extract_hours_for_every(hours))
      end
    end
    
    def dates
      @dates ||= []
    end

    #Execute this Trigger's code block if the datetime param matches this Trigger's cron entry.
    def execute_on_match(datetime)
      self.execute if cron_entry.matches?(datetime)
    end
    
    def execute
      defined?(ActiveRecord) ? execute_with_active_record : execute_without_active_record
    end
  
  
    private
    def cron_entry
      @cron_entry ||= CronEntry.new
    end
    
    #Raise an exception unless minutes and hours are set.
    def validate_hours_or_minutes!(options={})
      unless (options[:hours] || options[:hour]) || (options[:minutes] || options[:minute])      
        raise ChronoTrigger::ConfigurationException.new("Hours or minutes not specified in call to 'at' or 'every' method.") 
      end
    end
    
    def extract_minutes_for_every(minutes)
      extract_for_every(minutes, 60)
    end
    
    def extract_hours_for_every(hours)
      extract_for_every(hours, 24)
    end
    
    #Extract an array of integers representing the minutes or hours a task should be run at.
    #Raise an exception if time_value is not evenly divisible by base.
    def extract_for_every(time_value, base)
      unless (base % time_value == 0)
        raise ChronoTrigger::ConfigurationException.new("#{time_value} is not evenly divisible by #{base}.  Consider using #at instead.")
      end
      
      (0...base).select {|num| num % time_value == 0}      
    end
    
    # When ActiveRecord is defined, attempt to rescue ConnectionNotEstablished errors once,
    # and reestablish the connection to the database.  If this fails, normal exception logging will take place.
    # 
    def execute_with_active_record
      begin
        @exec_block.call
      rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::StatementInvalid
        ActiveRecord::Base.connection.reconnect!
        execute_without_active_record
      rescue Exception
        log_exception
      end      
    end
    
    # Execute the execution block and log all exceptions.
    #
    def execute_without_active_record
      begin
        @exec_block.call
      rescue Exception
        log_exception
      end            
    end
    
    def log_exception
      STDERR.puts "Exception #{$!.inspect} caught in Trigger##{self.name}.  Backtrace:"
      STDERR.puts $!.backtrace      
    end
  end
end