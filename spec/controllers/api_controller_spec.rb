require 'spec_helper'

describe ApiController do
  let(:user)  { FactoryGirl.create(:user) }
  let(:feed) { FactoryGirl.create(:feed) }
  let(:paper) { FactoryGirl.create(:paper) }

  before { sign_in user }

  describe "sciting a paper" do
    before do
      xhr :post, :scite, paper_uid: paper.uid
    end

    it "creates a scite and activity entry" do
      scite = Scite.where(user_id: user.id, paper_uid: paper.uid).first
      expect(scite).to_not be_nil

      activity = Activity.scite.where(user_id: user.id, subject_id: paper.id).first
      expect(activity).to_not be_nil

      expect(response).to be_success
    end
  end

  describe "unsciting a paper" do
    before do
      xhr :post, :scite, paper_uid: paper.uid
      xhr :post, :unscite, paper_uid: paper.uid
    end

    it "removes the scite and activity entry" do
      scite = Scite.where(user_id: user.id, paper_uid: paper.uid).first
      expect(scite).to be_nil

      activity = Activity.scite.where(user_id: user.id, subject_id: paper.id).first
      expect(activity).to be_nil

      expect(response).to be_success
    end
  end

  describe "subscribing to a feed" do
    before do
      xhr :post, :subscribe, feed_uid: feed.uid
    end

    it "creates a subscription and activity entry" do
      sub = Subscription.where(user_id: user.id, feed_uid: feed.uid).first
      expect(sub).to_not be_nil

      activity = Activity.subscribe.where(user_id: user.id, subject_id: feed.id).first
      expect(activity).to_not be_nil

      expect(response).to be_success
    end
  end

  describe "unsubscribing from a feed" do
    before do
      xhr :post, :subscribe, feed_uid: feed.uid
      xhr :post, :unsubscribe, feed_uid: feed.uid
    end

    it "removes the subscription and activity entry" do
      sub = Subscription.where(user_id: user.id, feed_uid: feed.uid).first
      expect(sub).to be_nil

      activity = Activity.subscribe.where(user_id: user.id, subject_id: feed.id).first
      expect(activity).to be_nil

      expect(response).to be_success
    end
  end

  describe "moderator: hiding a comment from recent comments" do
    let(:comment) { FactoryGirl.create(:comment) }
    let(:moderator) { FactoryGirl.create(:user, :moderator) }

    context "as a normal user" do
      before do
        xhr :post, :hide_from_recent, comment_id: comment.id
      end

      it "throws a 403" do
        expect(response).to_not be_success
        expect(comment.reload.hidden_from_recent).to be_false
      end
    end

    context "as a moderator" do
      before do
        sign_in moderator
        xhr :post, :hide_from_recent, comment_id: comment.id
      end

      it "hides the comment" do
        expect(response).to be_success
        expect(comment.reload.hidden_from_recent).to be_true
      end
    end
  end
end
