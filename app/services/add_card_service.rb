require 'payture'

class AddCardService

  def self.add_card_to_user(user)
    params = {
      OrderId:      SecureRandom.uuid   ,
      SessionType:  'Block'             ,
      Amount:       100                 ,
      TemplateTag:  'secondary'
    }
    initResult = init(user, params)

    query = {
      SessionId: initResult['Init']['SessionId']
    }

    url(initResult, query)
  end

  def self.add_card_to_booking(booking)
    params = {
      OrderId:      booking.order_token ,
      SessionType:  'Block'             ,
      Amount:       100                 ,
      Language:     I18n.locale.to_s
    }

    initResult = init(booking.user, params)

    query = {
      SessionId: initResult['Init']['SessionId'],
      pDate:      booking.service_date           ,
      pTime:      booking.service_time           ,
      pSubtotal:  booking.subtotal               ,
      pTotal:     booking.final_total            ,
      pDiscount:  booking.discount               ,
      pFrequency: I18n.t(booking.frequency.name) ,
      pPromo:     booking.promo_code
    }

    url(initResult, query)
  end

  private

  def self.init(user, params={})
    payload = {
      VWUserLgn:    user.email          ,
      VWUserPsw:    user.payture_token
    }
    payload.merge!(params)
    puts "payload: #{payload}"
    payture = Payture::Wallet.new(ENV['PAYTURE_HOST'])
    payture.init(ENV['PAYTURE_ADD'], payload)
  end

  def self.url(init, query)
    URI::HTTPS.build({
      host: ENV['PAYTURE_HOST']       ,
      path: '/vwapi/Pay'              ,
      query: query.to_query
    }).to_s
  end

end
