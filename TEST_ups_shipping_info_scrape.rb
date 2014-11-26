class TestUpsInfo
  def test_output()
    
    @a_hash = {
         date_delivered: 'Friday, 10/31/2014',
         time_delivered: '11:28 A.M.',
                left_at: 'Dock',
                address: '4455 148TH AVE NE BELLEVUE, WA, 98007, US',
              signed_by: 'MORGER',
      multiple_packages: '2',
              billed_on: '10/24/2014',
                   type: 'Package',
                 weight: '6.00 lbs',
          signature_pic: nil
    }
    
    return @a_hash
  end
  
end
