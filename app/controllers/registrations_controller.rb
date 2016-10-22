class RegistrationsController < Devise::RegistrationsController
  after_filter :set_create_notice, only: :create
  after_filter :handle_nonunique_email, only: :create
  after_filter :set_fake_update_message_for_nonunique_email

  def handle_nonunique_email
    if resource.user_facing_errors.empty? and resource.email_taken?
      user = User.where(:email => params[:user][:email]).first
      if user.confirmed?
        UserMailer.signup_attempt_with_existing_email(user).deliver_now
      else
        user.send_confirmation_instructions
      end
    end
  end

  def set_fake_update_message_for_nonunique_email
    flash[:notice] = I18n.t "devise.registrations.update_needs_confirmation"
  end

  def set_create_notice
    if resource.user_facing_errors.empty?
      cookies[:sweetAlert] = JSON.dump({title: "Thanks!", text: "A message with a confirmation link has been sent to your email address. Please open the link to activate your account."})
      flash[:notice] = nil
    end
  end

  def after_update_path_for(resource)
    registration_path(resource)
  end
end
