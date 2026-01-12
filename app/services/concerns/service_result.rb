module ServiceResult
  class Result
    attr_reader :value, :errors

    def initialize(success, value, errors = nil)
      @success = success
      @value = value
      @errors = errors
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def self.success(value)
      new(true, value)
    end

    def self.failure(errors)
      new(false, nil, errors)
    end
  end
end
