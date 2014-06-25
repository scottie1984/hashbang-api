require 'spec_helper'

describe Rating do

  let(:rating) { Rating.new(1, 2, 3, 4) }

  it { rating.should respond_to :userid }
  it { rating.userid.should eq 1 }
  it { rating.should respond_to :againstTag }
  it { rating.againstTag.should eq 2 }
  it { rating.should respond_to :objectId }
  it { rating.objectId.should eq 3 }
  it { rating.should respond_to :score }
  it { rating.score.should eq 4 }

end