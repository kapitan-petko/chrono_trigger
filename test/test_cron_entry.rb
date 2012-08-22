class TestCronEntry < Test::Unit::TestCase

  class << self
    
    def should_match(options={})
      context "and a datetime of #{options.inspect}" do
        setup do
          @datetime = time_from_options(options)
        end
        
        should "return true on a call to matches?" do
          assert @cron.matches?(@datetime)
        end
      end #and a datetime of options[]
    end
    
    def should_not_match(options={})
      context "and a datetime of #{options.inspect}" do
        setup do
          @datetime = time_from_options(options)
        end
        
        should "return false on a call to matches?" do
          assert !@cron.matches?(@datetime)
        end
      end #and a datetime of options[]      
    end

  end

  context "A CronEntry, @cron," do
    setup do
      @cron = ChronoTrigger::CronEntry.new
    end
    
    context "with a minutes entry of 10 minutes" do
      setup do
        @cron.set_minutes(10)
      end
      
      should_match(:minutes=>10)

      should_not_match(:minutes=>11)
      
      context "and 25 minutes" do
        setup do
          @cron.set_minutes(10, 25)
        end

        should_match(:minutes=>25)
        
        should_match(:minutes=>10)
        
        should_not_match(:minutes=>12)

        context "and a day entry of monday" do
          setup do
            @cron.set_days(:monday)
          end

          should_match(:minutes=>10, :wday=>1)
          
          should_not_match(:minutes=>10, :wday=>2)
          
          context "and wednesday" do
            setup do
              @cron.set_days(:monday, :wednesday)
            end

            should_match(:minutes=>10, :wday=>1)
            
            should_match(:minutes=>10, :wday=>3)
            
            should_not_match(:minutes=>25, :wday=>5)
            
            should_not_match(:minutes=>11, :wday=>3)
            
            context "and an hour entry of 2" do
              setup do
                @cron.set_hours(5)
              end

              should_match(:minutes=>25, :wday=>3, :hour=>5)
              
              should_not_match(:minutes=>25, :wday=>3, :hour=>6)
            end #and an hour entry of 2
          end #and wednesday
        end #and a day entry of monday
      end #and 25 minutes
    end #with a minutes entry of 10 minutes
    
    context "with a day entry of monday" do
      setup do
        @cron.set_days(:monday)
      end

      context "and no minutes_entry" do
        setup do
          @cron.set_minutes(nil)
        end
        
        should "raise a ChronoTrigger::CronEntry:ConfigException exception on matches?" do
          assert_raise ChronoTrigger::ConfigurationException do
            @cron.matches?(time_from_options)
          end
        end
      end #and no minutes_entry
    end #with a day entry
    
    context "with a calendar_day entry of 25" do
      setup do
        @cron.set_calendar_days(25)
      end
      
      should "raise an exception when setting a calendar_day and no hour and minutes" do
        assert_raise ChronoTrigger::ConfigurationException do
           @cron.matches?(time_from_options(:day => 25))
        end
      end
      
      context "with a hour entry of 10" do
        setup do
          @cron.set_hours(10)
        end
        
        should "raise an exception when setting a calendar_day and hour but no minutes" do
          assert_raise ChronoTrigger::ConfigurationException do
             @cron.matches?(time_from_options(:hour=> 10, :day => 25))
          end
        end
      
        context "with a minutes entry of 5" do
          setup do
            @cron.set_minutes(5)
          end
          
          should_match(:minutes => 5, :hour => 10, :day => 25)
          should_not_match(:minutes => 4, :hour => 10, :day => 25)
          should_not_match(:minutes => 5, :hour => 11, :day => 25)
          should_not_match(:minutes => 5, :hour => 10, :day => 26)
          
          context "with an additional calendar_day entry of 26" do
            setup do
              @cron.set_calendar_days([25, 26])
            end
            
            should_match(:minutes => 5, :hour => 10, :day => 25)
            should_match(:minutes => 5, :hour => 10, :day => 26)
            
            should "raise an exception when setting a calendar_day is outside the acceptable range" do
              assert_raise ChronoTrigger::ConfigurationException do
                @cron.set_calendar_days(-1)
              end
            end
          end
          
          context "with a day entry of tuesday" do
            setup do
              @cron.set_days(:wednesday)
            end
            
            should "raise an exception when setting a calendar_day with a day" do
              assert_raise ChronoTrigger::ConfigurationException do
                @cron.matches?(time_from_options(:minutes => 5, :hour => 10, :day => 25, :wday => 3))
              end
            end
          end
        end
      end
    end
        
    should "raise an exception when setting an hour entry greater than 25" do
      assert_raise ChronoTrigger::ConfigurationException do
        @cron.set_hours(25)
      end
    end
  end #A CronEntry, @cron,


  private 
  def time_from_options(options={})
    datetime = Time.utc(options[:year] || 2000,
             options[:month] || "jan",
             options[:day]||1,
             options[:hour]||0,
             options[:minutes]||0,
             options[:second]||0)
             
    if wday = options[:wday]
      while datetime.wday != wday
        datetime += 1.day
      end
    end
    
    datetime
  end

end