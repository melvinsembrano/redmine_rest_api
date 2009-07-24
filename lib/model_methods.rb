module ModelMethods

  module Attachment
    
    def download_url
      "/attachments/#{self.id}/#{self.filename}"
    end
  end
end