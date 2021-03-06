module Spec2
  class Context
    extend Matchers
    include Matchers

    LETS = [] of String
    BEFORE = [] of ->
    AFTER = [] of ->

    macro it(what, file = __FILE__, line = __LINE__, &block)
      instance.examples << ::Spec2::Example.new(self, {{what}}, {{file}}, {{line}}) do |ctx|
        (ctx as self).run_hook {{block}}
      end
    end

    macro describe(what, file = __FILE__, line = __LINE__, &block)
      ::Spec2.describe({{what}}, {{file}}, {{line}}) {{block}}
    end

    macro context(what, file = __FILE__, line = __LINE__, &block)
      describe({{what}}, {{file}}, {{line}}) {{block}}
    end

    macro before(&block)
      {% BEFORE << block %}
    end

    macro after(&block)
      {% AFTER << block %}
    end

    macro let(decl, &block)
      {% LETS << decl.id.stringify %}

      def {{decl.id}}
        __spec2_let_{{decl.id}}
      end

      def __spec2_let_{{decl.id}}
        {{decl.id}}! as typeof({{decl.id}}__spec2_typed)
      end

      def {{decl.id}}!
        (::Spec2.current_context as self).run_hook do
          {{decl.id}}__spec2_set
        end
      end

      def {{decl.id}}__spec2_set
        @_let_{{decl.id}} ||= {{decl.id}}__spec2_typed
      end

      def {{decl.id}}__spec2_typed
        {{block.body}}
      end

      def clear_lets
        super
        {% for name in LETS %}
             @_let_{{name.id}} = nil
        {% end %}
      end
    end

    macro let!(decl, &block)
      let({{decl}}) {{block}}
      before { {{decl.id}} }
    end

    macro subject(&block)
      {% if block.is_a?(Nop) %}
           __spec2_let_subject
      {% else %}
           let(subject) {{block}}
      {% end %}
    end

    macro subject(decl, &block)
      let({{decl}}) {{block}}
    end

    def self.instance
      ContextRegistry.instance_of(self)
    end

    def self.parent
      ContextRegistry.parent_of(self)
    end

    def self.expect(actual)
      Expectation.new(actual)
    end

    def self.expect(&block)
      Expectation.new(block)
    end

    macro def run_before_hooks(ctx) : Nil
      parent_run_before_hooks(ctx)
      {% for hook in BEFORE %}
           ctx.run_hook {{hook}}
      {% end %}
      nil
    end

    macro def run_after_hooks(ctx) : Nil
      parent_run_after_hooks(ctx)
      {% for hook in AFTER %}
           ctx.run_hook {{hook}}
      {% end %}
      nil
    end

    def parent_run_before_hooks(ctx)
      return unless parent = self.class.parent
      parent.instance.run_before_hooks(ctx)
    end

    def parent_run_after_hooks(ctx)
      return unless parent = self.class.parent
      parent.instance.run_after_hooks(ctx)
    end

    def run_hook
      with self yield
    end

    def examples
      @_examples ||= [] of Example
    end

    def contexts
      @_contexts ||= [] of Context
    end

    def clear_lets
    end

    def description
      ""
    end

    def description
      ""
    end

    def what
      ""
    end

    def file
      "spec2_root_context"
    end

    def line
      1
    end
  end

  class DumbContextSubclass < Context
  end

  class ContextRegistry
    @@contexts = {
      Context.to_s => Context.new,
      DumbContextSubclass.to_s => DumbContextSubclass.new,
    }

    @@parents = {
      Context.to_s => Context,
      DumbContextSubclass.to_s => DumbContextSubclass,
    }

    def self.clear
      @@contexts.clear
      @@parents.clear
    end

    def self.instance_of(klass)
      @@contexts[klass.to_s] ||= klass.new as Context
    end

    def self.register_parent(klass, parent)
      @@parents[klass.to_s] = parent
    end

    def self.parent_of(klass)
      @@parents[klass.to_s]?
    end
  end

  ContextRegistry.clear
end
