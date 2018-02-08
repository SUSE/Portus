# frozen_string_literal: true

module API
  module V1
    # Tags implements all the endpoints regarding tags that have not been
    # addressed in other classes.
    class Vulnerabilities < Grape::API
      version "v1", using: :path

      resource :vulnerabilities do
        before do
          authorization!(force_admin: true)
        end

        desc "Force re-schedule for all tags",
             tags:    ["vulnerabilities"],
             detail:  "Force the security scanner to go through all the tags" \
                      " again, even if they have been marked as scanned",
             failure: [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        post do
          Tag.update_all(scanned: Tag.statuses[:scan_none])
          status 202
        end

        route_param :id, type: Integer, requirements: { id: /.*/ } do
          desc "Force re-schedule for the given tag",
               tags:    ["vulnerabilities"],
               detail:  "Force the security scanner to scan again a given tag," \
                        "even if it was already marked as scanned",
               failure: [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"]
               ]

          post do
            tag = Tag.find(params[:id])
            tag.update_column(:scanned, Tag.statuses[:scan_none])
            status 202
          end
        end
      end
    end
  end
end
