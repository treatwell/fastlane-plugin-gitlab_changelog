require 'fastlane/action'
require_relative '../helper/gitlab_changelog_helper'

module Fastlane
  module Actions
    class GitlabChangelogAction < Action
      def self.run(params)
        require 'excon'

        to_branch = params[:current_branch].to_s
        from_branch = Helper::GitlabChangelogHelper.get_from_branch(params[:compare_branch_prefix].to_s, to_branch)
        endpoint = "#{params[:gitlab_API_baseURL]}/projects/#{params[:gitlab_project_id]}/repository/compare"

        UI.message("Fetching changeLog from: #{from_branch} to: #{to_branch} (GET #{endpoint})")

        compare_resp = Excon.get(
          endpoint,
          query: {
            from: from_branch,
            to: to_branch,
            private_token: params[:gitlab_API_token]
          }
        )

        change_log = JSON.parse(compare_resp.body)['commits']
                         .reject { |c| c['title'].start_with?("Merge branch") } # Filter out merges
                         .sort_by { |c| -Date.parse(c['created_at']).to_time.to_i }
                         .map { |c| "#{c['title']} (#{c['author_name']}) #{Date.parse(c['created_at'])}" }
                         .join("\n")

        puts("\n#{change_log}")

        change_log
      end

      def self.description
        "Get changelog using GitLab API"
      end

      def self.authors
        ["Žilvinas Sebeika"]
      end

      def self.return_value
        "String containing commit messages (excluding branch merges). Separated by new_line"
      end

      def self.details
        "Fetch changelog between branches using GitLab API. Useful if you have GIT_DEPTH: 1 setting in CI config"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :current_branch,
                                        env_name: "CI_COMMIT_REF_NAME",
                                        description: "Current branch",
                                        optional: false),
          FastlaneCore::ConfigItem.new(key: :compare_branch_prefix,
                                        default_value: "release",
                                        description: "Compare branch prefix. Usually 'release' to compare against 'release/*.*.*' branches",
                                        optional: false),
          FastlaneCore::ConfigItem.new(key: :gitlab_API_baseURL,
                                        description: "GitLab API base URL (http://<gitLab_host>/api/v4)",
                                        optional: false),
          FastlaneCore::ConfigItem.new(key: :gitlab_project_id,
                                        env_name: "CI_PROJECT_ID",
                                        description: "GitLab Project ID (ENV['CI_PROJECT_ID'])",
                                        optional: false),
          FastlaneCore::ConfigItem.new(key: :gitlab_API_token,
                                        description: "GitLab API Token (ENV['GITLAB_API_TOKEN'])",
                                        optional: false)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
