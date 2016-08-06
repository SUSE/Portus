module SearchHelper
  def build_search_category_url(params, category)
    "#{search_index_path}?utf8=#{params[:utf8]}&search=#{params[:search]}&type=#{category}"
  end

  def dynamic_filter_input(action)
    form_tag action, method: 'get', id: 'filter_form', class: 'input-group shared-search filter-wrapper' do
      concat(content_tag :i, nil, class: 'fa fa-filter')
      concat(text_field_tag :filter, params[:filter], id: 'filter_input', class: 'form-control filter-input', placeholder: 'Filter')
    end
  end
end
