module LinkHelpers
  # Give us some sane link helpers to work with in Phlex. They kind
  # of mimic Rails helpers, but are "Phlexable".
  def link_to(target, **attributes, &)
    a(href: url_for(target), **attributes, &)
  end

  def show(model, attribute = nil, *args, **kwargs, &content)
    content ||= Proc.new { model.send(attribute) } if attribute
    link_to(model, *args, **kwargs, &content)
  end

  def edit(model, *args, **kwargs, &content)
    content ||= Proc.new { "Edit #{model.class.model_name}" }
    link_to([:edit, model],  *args, **kwargs, &content)
  end

  def delete(model, *args, data: {}, **kwargs, &content)
    content ||= Proc.new { "Delete #{model.class.model_name}" }
    link_to(model, *args, data: data.merge("turbo-method": :delete), **kwargs, &content)
  end

  def create(scope = nil, *args, **kwargs, &content)
    target = if scope.respond_to? :proxy_association
      owner = scope.proxy_association.owner
      model = scope.proxy_association.reflection.klass.model_name
      element = scope.proxy_association.reflection.klass.model_name.element.to_sym
      [:new, owner, element]
    elsif scope.respond_to? :model
      model = scope.model
      [:new, model.model_name.element.to_sym]
    else
      model = scope
      [:new, scope]
    end

    content ||= Proc.new { "Create #{model}" }

    link_to(target, *args, **kwargs, &content)
  end
end