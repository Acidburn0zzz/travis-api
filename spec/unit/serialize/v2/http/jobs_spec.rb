describe Travis::Api::Serialize::V2::Http::Jobs do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { described_class.new([test]).data }
  let!(:time) { Time.now.utc }

  [
    {},
    { include_log_id: true }
  ].each do |options|
    it 'jobs', logs_api_enabled: false do
      instance = described_class.new([test])
      instance.serialization_options = options
      serialized = instance.data
      serialized['jobs'].first.should == {
        'id' => 1,
        'repository_id' => 1,
        'repository_slug' => 'svenfuchs/minimal',
        'build_id' => 1,
        'stage_id' => 1,
        'commit_id' => 1,
        'number' => '2.1',
        'state' => 'passed',
        'started_at' => json_format_time(time - 1.minute),
        'finished_at' => json_format_time(time),
        'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
        'queue' => 'builds.linux',
        'allow_failure' => false,
        'tags' => 'tag-a,tag-b'
      }.tap do |expected|
        expected['log_id'] = 1 if options[:include_log_id]
      end
    end
  end

  it 'commits' do
    data['commits'].first.should == {
      'id' => 1,
      'sha' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'tag' => nil,
      'message' => 'the commit message',
      'committed_at' => json_format_time(time - 1.hour),
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
    }
  end

  describe 'with a tag' do
    before do
      test.commit.stubs(tag_name: 'v1.0.0')
    end

    it 'includes the tag name to commit' do
      data['commits'][0]['tag'].should == 'v1.0.0'
    end
  end
end

describe Travis::Api::Serialize::V2::Http::Jobs, 'using Travis::Services::Jobs::FindAll' do
  let(:jobs) { Travis.run_service(:find_jobs, nil) }
  let(:data) { described_class.new(jobs).data }

  before :each do
    3.times { Factory(:test) }
  end

  it 'queries', logs_api_enabled: false do
    lambda { data }.should issue_queries(4)
  end

  it 'does not explode' do
    data.should_not be_nil
  end
end
