class StaffPlanFormBuilder < ActionView::Helpers::FormBuilder

  %w[text_field text_area password_field check_box select].each do |method_name|
    define_method(method_name) do |field_name, *args|
      @template.content_tag :div, :class => "input" do
        label(field_name) + super(field_name, *args)
      end
    end
  end

end

