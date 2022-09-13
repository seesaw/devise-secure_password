require 'spec_helper'

shared_examples_for 'a submission with a bad password' do |error_regex|
  before do
    user.save
    login_as(user, scope: :user)
    visit '/users/change_password/edit'
  end

  it 'remains on page and displays error messages', js: true do
    expect(page).to have_content(/Change your password/i)
    fill_in 'user_current_password', with: current_password
    fill_in 'user_password', with: new_password
    fill_in 'user_password_confirmation', with: new_password_confirmation
    find(:xpath, ".//input[@type='submit' and @name='commit']").click

    expect(page).to have_content(/Change your password/i)
    within '#error_explanation' do
      expect(page).to have_content(error_regex)
    end
  end
end

shared_examples_for 'a submission with a bad password confirmation' do |error_regex|
  before do
    user.save
    login_as(user, scope: :user)
    visit '/users/change_password/edit'
  end

  it 'remains on page and displays error messages', js: true do
    expect(page).to have_content(/Change your password/i)
    fill_in 'user_current_password', with: current_password
    fill_in 'user_password', with: new_password
    fill_in 'user_password_confirmation', with: new_password_confirmation
    find(:xpath, ".//input[@type='submit' and @name='commit']").click

    expect(page).to have_content(/Change your password/i)
    within '#error_explanation' do
      expect(page).to have_content(error_regex)
    end
  end
end

shared_examples_for 'a submission with multiple new password errors' do |error_messages|
  before do
    user.save
    login_as(user, scope: :user)
    visit '/users/change_password/edit'
  end

  it 'remains on page and displays error messages', js: true do
    expect(page).to have_content(/Change your password/i)
    fill_in 'user_current_password', with: password
    fill_in 'user_password', with: bad_password
    fill_in 'user_password_confirmation', with: bad_password
    find(:xpath, ".//input[@type='submit' and @name='commit']").click

    expect(page).to have_content(/Change your password/i)
    within '#error_explanation' do
      error_messages.each do |error_message|
        expect(page).to have_content(error_message)
      end
    end
  end
end
