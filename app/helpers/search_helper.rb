module SearchHelper
  def build_search_category_url(params, category)
    "#{search_index_path}?utf8=#{params[:utf8]}&search=#{params[:search]}&type=#{category}"
  end

  def dynamic_filter_input(action, param_name: "filter", form_id: "filter_form")
    form_classes = "input-group shared-search filter-wrapper"
    form_tag action, method: "get", id: form_id, class: form_classes do
      concat(content_tag(:i, nil, class: "fa fa-filter"))
      concat(text_field_tag(param_name, params[param_name], id: param_name,
        class: "form-control filter-input", placeholder: "Filter"))
      concat(javascript_tag("activateFilter('##{param_name}', '##{form_id}');"))
    end
  end
end
