module Envestigators
  class BuildNumber
    EnvestigateNew = "/envestigate/new"

    @queue = :webdriver_queue

    def self.perform(environment_id)
      environment = Environment.find(environment_id)

      Envy.driver.load(environment.code, environment.url)
      build_number = Envy.driver.build_number
      Envy.driver.screenshot_build_number

      #PrivatePub.publish_to(EnvestigateNew, update_results_with(environment, "Build Number: #{build_number}"))
      PrivatePub.publish_to(EnvestigateNew,
                           {:env => environment.code.gsub(/ /, '-'),
                            :envestigation => 'build-number',
                            :message => "Build Number: #{build_number}",
                            :screenshot => "build.png"})
    rescue Selenium::WebDriver::Error::NoSuchElementError
      #PrivatePub.publish_to(EnvestigateNew, update_results_with(environment, "Error. :( I couldn't find it.", ".addClass('error')"))
      PrivatePub.publish_to(EnvestigateNew,
                           {:env => environment.code.gsub(/ /, '-'),
                            :envestigation => 'build-number',
                            :message => "Error. :( I coulndn't find it.",
                            :add_class => 'error'})
    end

    def self.update_results_with(env, html, chain='')
      "$(\"##{env.code.gsub(/ /, '-')}-results\").removeClass('loading')" +
        ".html(\"#{html}\")#{chain};"  # TODO escape quotes or... whatever, js
    end
  end
end

