require 'rails_helper'

describe Entry do

  context "validations" do
    it { should validate_presence_of(:content_id) }
    it { should allow_value('000b4062-8eaa-45ea-ba3c-7c6683a8cbbe').for(:content_id) }
    it { should_not allow_value('000B4062-8EAA-45EA-BA3C-7C6683A8CBBE').for(:content_id) }
    it { should_not allow_value('000-b40-628-eaa-45e-aba-3c7-c66-83a-8cbbe').for(:content_id) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:format) }
  end

end
