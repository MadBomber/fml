module FML
  # Validations classes have two required methods:
  #
  #   initialize(field, data, form)
  #     create the validation. `field` is the FMLField object representing
  #     the field in which the validation was created. `data` is the value
  #     given to in the FML spec. `form` is the FMLForm within which the field
  #     was created.
  #
  #   Given a spec like:
  #    form:
  #      title: "Validation Example"
  #      version: "1"
  #      fieldsets:
  #        - fieldset:
  #          - field:
  #              name: "validate"
  #              fieldType: "text"
  #              label: "Dependent"
  #              validations:
  #                - minLength: 10
  #
  #   `field` would be the object represting the `validate` field, `data` would
  #   be 10, and form would be the object representing the entire form spec.
  #
  #   validate()
  #     validate that the condition the validation represents is true. Raises
  #     an FML::ValidationError if it's not, otherwise may return anything
  #
  # ideas: GreaterThan, LessThan, EarlierThan, LaterThan

  class RequiredIfValidation
    def initialize(field, data, form)
      @negative = data.start_with? "!"

      # If the assertion is negative, we require the parent to be true, and
      # vice versa
      @required = !@negative

      # strip the ! if there was one
      data = data[1..-1] if @negative

      @child = field
      @parent = form.fields[data]
    end

    def validate
      # if parent is @required, child must be non-empty. Note that @parent is
      # required to be a boolean element, so we don't need to worry about ""
      # being a truthy value
      if @parent.value == @required && @child.empty?
        debug_message = <<-EOM
Field #{@child.name}:#{@child.value.inspect} must be present when #{@parent.name}:#{@parent.value.inspect} is #{@required}
        EOM
        user_message = "This field is required"
        err = DependencyError.new(user_message, debug_message, @child.name, @parent.name)
        @child.errors << err
        raise err
      end
    end
  end

  class MinLengthValidation
    def initialize(field, data, form)
      @field = field
      @minlength = data
    end

    def validate
      # @field must be either nil or have length >= minLength
      if @field.value && @field.value.length < @minlength
        debug_message = <<-EOM
Field #{@field.name}:#{@field.value.inspect} must be longer than #{@minlength} characters
        EOM
        user_message = "Must be longer than #{@minlength} characters"
        err = ValidationError.new(user_message, debug_message, @field.name)
        @field.errors << err
        raise err
      end
    end
  end
end