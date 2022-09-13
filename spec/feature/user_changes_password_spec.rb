require 'spec_helper'

RSpec.describe 'User changes password', type: :feature do
  let(:password) { 'Bubb1234%$#X' }
  let(:current_password) { password }
  let(:new_password) { 'Bubb1234%$#$' }
  let(:new_password_confirmation) { new_password }
  let(:user) do
    User.new(
      email: 'betty@rubble.com',
      password: password,
      password_confirmation: password
    )
  end

  before do
    Devise.setup { |config| config.password_minimum_age = 0.days }
  end

  after do
    Devise.setup { |config| config.password_minimum_age = 1.day }
  end

  context 'when minimum age enforcement is enabled' do
    before do
      Devise.setup { |config| config.password_minimum_age = 1.day }
      user.save
      login_as(user, scope: :user)
      visit '/users/change_password/edit'
    end

    it 'remains on page and displays recently changed error message', js: true do
      expect(page).to have_content(/Change your password/i)
      fill_in 'user_current_password', with: password
      fill_in 'user_password', with: new_password
      fill_in 'user_password_confirmation', with: new_password
      find(:xpath, ".//input[@type='submit' and @name='commit']").click

      expect(page).to have_content(/Change your password/i)
      within '#error_explanation' do
        expect(page).to have_content(/Password cannot be changed more than once per 1 day/i)
      end
    end
  end

  context 'with an incorrect current password' do
    let(:current_password) { "#{user.password}Y" }

    it_behaves_like 'a submission with a bad password', /Current password is invalid/i
  end

  context 'with a blank current password' do
    let(:current_password) { '' }

    it_behaves_like 'a submission with a bad password', /Current password can't be blank/i
  end

  context 'with an invalid new password' do
    uppercase_range = Regexp.escape('(A..Z)')
    numeric_range = Regexp.escape('(0..9)')
    special_range = Regexp.escape("( !@\#$%^&*()_+-=[]{}|\"/\\.,`<>:;?~')")
    error_messages = [
      /Password must contain at least 1 uppercase character #{uppercase_range}/,
      /Password must contain at least 1 number character #{numeric_range}/,
      /Password must contain at least 1 special character #{special_range}/,
      /Password confirmation must contain at least 1 uppercase character #{uppercase_range}/,
      /Password confirmation must contain at least 1 number character #{numeric_range}/,
      /Password confirmation must contain at least 1 special character #{special_range}/
    ]

    context 'when new password is invalid' do
      let(:bad_password) { 'a' * 12 }

      it_behaves_like 'a submission with multiple new password errors', error_messages
    end

    context 'when new password is blank' do
      let(:bad_password) { '' }

      it_behaves_like 'a submission with multiple new password errors', error_messages
    end
  end

  context 'with an invalid new non-latin password' do
    before do
      Devise.setup do |config|
        config.password_required_anycase_count = 4
        config.password_character_counter_class = Support::String::MultiLangCharacterCounter
      end
    end

    after do
      Devise.setup do |config|
        config.password_required_anycase_count = nil
        config.password_character_counter_class = Support::String::CharacterCounter
      end
    end

    context 'when new password is invalid' do
      let(:bad_password) { 'خزا' }

      it_behaves_like 'a submission with multiple new password errors', [
        /Password must contain at least 4 anycase characters/,
        /Password must contain at least 1 number character/,
        /Password must contain at least 1 special character/,
        /Password confirmation must contain at least 4 anycase characters/,
        /Password confirmation must contain at least 1 number character/,
        /Password confirmation must contain at least 1 special character/
      ]
    end

    context 'when new password is blank' do
      let(:bad_password) { '' }

      it_behaves_like 'a submission with multiple new password errors', [
        /Password must contain at least 6 characters/,
        /Password must contain at least 1 number character/,
        /Password must contain at least 1 special character/,
        /Password confirmation must contain at least 6 characters/,
        /Password confirmation must contain at least 1 number character/,
        /Password confirmation must contain at least 1 special character/
      ]
    end
  end

  context 'with a non-matching new password and confirmation' do
    let(:new_password_confirmation) { "#{new_password}Z" }

    it_behaves_like 'a submission with a bad password', /Password confirmation doesn't match Password/i
  end

  context 'with a blank new password confirmation' do
    let(:new_password_confirmation) { ' ' }

    it_behaves_like 'a submission with a bad password', /Password confirmation must contain at least 6 characters/i
  end

  context 'with a valid password' do
    let(:new_password) { "#{user.password}Z" }

    before do
      user.save
      last_password = user.previous_passwords.first
      last_password.created_at = 2.days.ago
      last_password.save
      login_as(user, scope: :user)
      visit '/users/change_password/edit'
    end

    it 'redirects to home page and displays success message', js: true do
      fill_in 'user_current_password', with: password
      fill_in 'user_password', with: new_password
      fill_in 'user_password_confirmation', with: new_password
      find(:xpath, ".//input[@type='submit' and @name='commit']").click

      expect(page).to have_content(/Your password has been updated/i)
      expect(page).not_to have_selector('#error_explanation')
    end
  end
end
