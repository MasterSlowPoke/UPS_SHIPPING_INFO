require 'chunky_png'

class UpsInfo
  def test_output()
    
    a_hash = {
      date_delivery:  'Friday, 10/31/2014'
      time_delivery:  '11:28 A.M.'
      left_at:        'Dock'
      address:        'BELLEVUE, WA, US'
      signed_by:      'MORGER'
      signature_link: '<-- enter link of the picture -->'
    }
    
    return a_hash
  end
  
end