module Fastlane
  module Helper
    class GitlabChangelogHelper
      def self.get_depth(name, current_branch)
        current_branch.start_with?(name) ? 2 : 1
      end

      # If the current branch is a branch we're comparing to ("release/*.*.*" for example) -
      # then pick depth = 2 to get a previous version number for the changelog.
      # Otherwise - use the latest version as a reference branch.
      def self.get_from_branch(name, current_branch)
        depth = get_depth(name, current_branch)
        reference_branch = Action.sh("git ls-remote --sort='v:refname' --quiet --heads origin refs/heads/#{name}/* | tail -n #{depth} | head -n 1 | awk '{ printf \"%s\", $2 }' | rev | cut -d/ -f1 | rev | xargs echo -n")
        return "#{name}/#{reference_branch}"
      end
    end
  end
end
