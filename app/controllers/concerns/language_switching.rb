module LanguageSwitching
  extend ActiveSupport::Concern
  def set_language(lang)
    I18n.locale = lang.presence || I18n.default_locale
  end
end