require 'test_helper'
require "#{Rails.root}/test/features/support/agreement_creation_helper"

class AgreementTest < ActiveSupport::TestCase
  include AgreementCreationHelper

  test 'New AgreementRevision is created when an Agreement is created' do
    agreement = create_valid_agreement!(organizations(:sii) , (organizations(:segpres)))
    assert agreement.agreement_revisions.exists?
  end

  test '#last_revision_number returns the version number of the last agreement revision' do
    agreement = create_valid_agreement!(organizations(:sii) , (organizations(:segpres)))
    assert_equal 1, agreement.last_revision_number
    agreement.agreement_revisions.create(user: users(:perico))
    assert_equal 2, agreement.last_revision_number
    agreement.agreement_revisions.create(user: users(:perico))
    assert_equal 3, agreement.last_revision_number
  end

  test '.user_can_update_agreement_status? returns true for user than can update status' do
    agreement = create_valid_agreement!(organizations(:sii) , (organizations(:segpres)))
    assert agreement.user_can_update_agreement_status?(users(:pablito))
  end

  test '.user_can_update_agreement_status? return false for user that can\'t update status' do
    agreement = create_valid_agreement!(organizations(:sii) , (organizations(:segpres)))
    assert_not agreement.user_can_update_agreement_status?(users(:pedro))
  end
  
end
