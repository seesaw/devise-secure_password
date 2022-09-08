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

shared_examples_for 'a submission with multiple new password errors' do
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
      expect(page).to have_content(/Password must contain at least 1 uppercase character #{uppercase_range}/)
      expect(page).to have_content(/Password must contain at least 1 number character #{numeric_range}/)
      expect(page).to have_content(/Password must contain at least 1 special character #{special_range}/)
      expect(page).to have_content(/Password confirmation must contain at least 1 uppercase character #{uppercase_range}/)
      expect(page).to have_content(/Password confirmation must contain at least 1 number character #{numeric_range}/)
      expect(page).to have_content(/Password confirmation must contain at least 1 special character #{special_range}/)
    end
  end
end

shared_examples_for 'a submission with multiple new non-latin password errors' do |anycase_count|
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
      expect(page).to have_content(/Password must contain at least #{anycase_count} anycase characters/)
      expect(page).to have_content(/Password must contain at least 1 number character/)
      expect(page).to have_content(/Password must contain at least 1 special character/)
      expect(page).to have_content(/Password confirmation must contain at least #{anycase_count} anycase characters/)
      expect(page).to have_content(/Password confirmation must contain at least 1 number character/)
      expect(page).to have_content(/Password confirmation must contain at least 1 special character/)
    end
  end
end
