class StaffPlanFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(attribute, options={})
    @template.content_tag :div, :class => "input" do
      label(attribute) + super
    end
  end

  def password_field(attribute, options={})
    @template.content_tag :div, :class => "input" do
      label(attribute) + super
    end
  end

end

