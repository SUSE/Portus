# frozen_string_literal: true

# Extracted and adapted from https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/api/helpers/pagination.rb

module API
  module Helpers
    # Pagination implements a helper responsible for the resource entries pagination
    # that can be customized through request parameters like `all`, `page` and `per_page`.
    module Pagination
      def paginate(relation)
        return relation if params[:all].present?

        relation.page(params[:page]).per(params[:per_page]).tap do |data|
          add_pagination_headers(data)
        end
      end

      private

      def add_pagination_headers(paginated_data)
        header "X-Per-Page",    APP_CONFIG["pagination"]["per_page"]
        header "X-Page",        paginated_data.current_page.to_s
        header "X-Next-Page",   paginated_data.next_page.to_s
        header "X-Prev-Page",   paginated_data.prev_page.to_s
        header "X-Total",       paginated_data.total_count.to_s
        header "X-Total-Pages", total_pages(paginated_data).to_s

        return if params[:action] && params[:controller]

        header "Link", pagination_links(paginated_data)
      end

      def pagination_links(paginated_data)
        request_url = request.url.split("?").first
        request_params = params.clone
        request_params[:per_page] = paginated_data.limit_value

        links = []

        request_params[:page] = paginated_data.prev_page
        links << %(<#{request_url}?#{request_params.to_query}>; rel="prev") if request_params[:page]

        request_params[:page] = paginated_data.next_page
        links << %(<#{request_url}?#{request_params.to_query}>; rel="next") if request_params[:page]

        request_params[:page] = 1
        links << %(<#{request_url}?#{request_params.to_query}>; rel="first")

        request_params[:page] = total_pages(paginated_data)
        links << %(<#{request_url}?#{request_params.to_query}>; rel="last")

        links.join(", ")
      end

      def total_pages(paginated_data)
        # Ensure there is in total at least 1 page
        [paginated_data.total_pages, 1].max
      end
    end
  end
end
