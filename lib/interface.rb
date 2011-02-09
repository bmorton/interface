# Implementable interfaces in ruby
module Interface
  autoload :Abstract, 'interface/abstract'
  autoload :Version,  'interface/version'

  # Takes a module (or multiple in reverse order), extends it with <tt>Interface::Abstract</tt>, then includes it into the current object
  #
  # Example
  #
  #   module Remote
  #     # turns the device on
  #     def on
  #     end
  #   end
  #
  #   class Device
  #     implements Remote
  #
  #     def on
  #       @power = true
  #     end
  #   end
  def implements(*modules)
    modules.flatten.reverse!.each { |mod| include mod.extend(Abstract) }
  end

  # Conforms with naming conventions for include and extend
  alias_method :implement, :implements

  # Returns an array of interfaces implemented by the current object
  def interfaces
    included_modules.select { |mod| mod.is_a?(Abstract) }
  end

  # Returns a hash with each partially implemented <tt>interface</tt> as keys and an array of methods 
  # that the current object does not implement as values
  def unimplemented_methods
    self.class.interfaces.inject({}) do |hash, interface|
      methods = unimplemented_methods_for(interface)
      methods.empty? ? hash : hash.merge!(interface => methods)
    end
  end

  # Returns an array of methods from the specified <tt>interface</tt> that the current object does not implement
  def unimplemented_methods_for(interface)
    interface.instance_methods(false).reject do |method|
      method = method.to_sym
      (respond_to?(method, true) && self.method(method).owner != interface) || (respond_to?(:respond_to_missing?, true) && respond_to_missing?(method, true))
    end.sort
  end
end

Object.send(:include, Interface)