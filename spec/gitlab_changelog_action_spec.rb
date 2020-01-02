describe Fastlane::Actions::GitlabChangelogAction do
  describe '#run' do
    before do
      allow(FastlaneCore::Helper).to receive(:sh_enabled?).and_return(true)
    end
    before(:each) do
      Excon.defaults[:mock] = true
      Excon.stub({}, { body: File.read("./spec/fixtures/requests/gitlab_compare_branches_response.json"), status: 200 })
    end

    after(:each) do
      Excon.stubs.clear
    end

    it 'constructs changeLog' do
      expect_command("git ls-remote --sort='v:refname' --quiet --heads origin refs/heads/myReleaseBranches/* | tail -n 1 | head -n 1 | awk '{ printf \"%s\", $2 }' | rev | cut -d/ -f1 | rev | xargs echo -n", exitstatus: 0, output: "1.2.0")
      expect(Fastlane::UI).to receive(:message).with("Fetching changeLog from: myReleaseBranches/1.2.0 to: develop (GET http://git.mycompany.net/api/v4/projects/100/repository/compare)")

      params = {
        current_branch: "develop",
        compare_branch_prefix: "myReleaseBranches",
        gitlab_API_baseURL: "http://git.mycompany.net/api/v4",
        gitlab_project_id: 100,
        gitlab_API_token: "some123token"
      }
      output = Fastlane::Actions::GitlabChangelogAction.run(params)

      expect(output).to eq("Feature 2 (Developer 2) 2019-12-31\nFeature 1 (Developer 1) 2019-12-30")
    end
  end

  describe '#is_supported' do
    it "supports all platforms" do
      expect(Fastlane::Actions::GitlabChangelogAction.is_supported?('anyPlatform')).to eq(true)
    end
  end
end

def expect_command(*command, exitstatus: 0, output: "")
  mock_input = double(:input)
  mock_output = StringIO.new(output)
  mock_status = double(:status, exitstatus: exitstatus)
  mock_thread = double(:thread, value: mock_status)

  expect(Open3).to receive(:popen2e).with(*command).and_yield(mock_input, mock_output, mock_thread)
end
