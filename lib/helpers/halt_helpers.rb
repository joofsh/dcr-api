module HaltHelpers
  def halt(status, headers: {}, body: '')
      body = body.to_json unless body.is_a? String
        super(status, headers, body)
  end

  def no_content!
      halt 204
  end

  def bad_request!(message = 'Bad Request')
      halt 400, body: { errors: message }
  end

  def forbidden!(message = 'Forbidden')
      halt 403, body: { errors: message }
  end

   def not_found!(message = 'Resource Not Found')
     halt 404, body: { errors: message }
   end

    def unprocessable_entity!(message = 'Unprocessable Entity')
      halt 422, body: { errors: message }
    end
end
