// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract PBS {
  enum ReceivedStatus { Unreceived, Unacceptable, Broken, UnacceptableAndBroken, Normal, Good, Excelent }
  enum OfferType { Single, Bid }

  string public name;
  uint public badgesCount = 0;
  uint public servicesCount = 0;

  mapping( uint => Badge) public badges;
  mapping( uint => Offer) public offers;
  mapping( uint => Prove) public proves;
  mapping( uint => Status) public status;
  mapping( uint => Service) public services;
  mapping( uint => Balance) public balances;

    struct Evaluator {
        uint8 hit_rate;
        uint32 works_performed;
        string description;
        string language;
        address owner;
        Balance balance;
    }

    struct Service {
        uint id;
        string name;
        string description;
        string language;
        uint activeEvaluators;
        mapping(address => Evaluator) evaluators;
    }
    
    struct Balance {
        uint256 total;
        bool blocked;
    }
    
    struct Badge {
        uint id;
        string name;
        uint price;
        address buyer;
        address owner;
    }
    
    struct Offer {
        uint8 offers;
        uint8 max_offers;
        OfferType offer_type;
    }
    
    struct Prove {
        string url;
        string files_hash;
        uint8 confiddence;
    }
    
    struct Status {
        bool on_sale;
        bool purchased;
        uint256 sended_date;
        uint256 received_date;
        ReceivedStatus  received_status;
    }
    
    event BadgeCreated(
      uint id,
      string name,
      OfferType offer_type,
      address owner
    );
    
    event BadgePurchased(
      uint id,
      string name,
      OfferType offer_type,
      address buyer
    );
    
    constructor() {
      name = 'Product Buy System';
    }
    
    function createOffer(uint _id, OfferType _offer_type) private {
      offers[_id] = Offer({
          offers: 0,
          max_offers: 1,
          offer_type: _offer_type
        });
    }
    
    function createProve(uint _id) private {
      proves[_id] = Prove({
          url: "",
          files_hash: "",
          confiddence: 0
        });
    }
    
    function createStatus(uint _id) private {
      status[_id] = Status({
          on_sale: false,
          purchased: false,
          sended_date: 0,
          received_date: 0,
          received_status: ReceivedStatus.Unreceived
        });
    }
    
    function buyBadge(string memory _name, OfferType _offer_type) public {
      require(bytes(_name).length > 0);
      require(OfferType.Single == _offer_type || OfferType.Bid == _offer_type);
    
      badgesCount ++;
    
      createProve(badgesCount);
      createOffer(badgesCount, _offer_type);
      createStatus(badgesCount);
    
      badges[badgesCount] = Badge({
        id: badgesCount,
        name: _name,
        price: 0,
        buyer: address(0),
        owner: msg.sender
        });
    
      emit BadgeCreated({
          id: badgesCount,
          name: _name,
          offer_type: _offer_type,
          owner: msg.sender
        });
    }
    
    function registerService(string memory _name, string memory _description, string memory _language) public {
        require(bytes(_name).length > 0);
        require(bytes(_description).length > 20);
        require(bytes(_language).length > 0);
    
    
        Service storage newService = services[servicesCount++];
        
        newService.id = servicesCount;
        newService.name = _name;
        newService.description = _description;
        newService.language = _language;
        newService.activeEvaluators = 0;
        
    }
    
    function registerEvaluator(string memory _description, string memory _language, uint _service_id) public {
        require(services[_service_id].id > 0, "Service doesn't exists");
        require(bytes(_description).length > 0);
        require(bytes(_language).length > 0);
    
        Service storage service = services[_service_id];
    
        Balance memory balance = Balance({
                              total: 10,
                              blocked: true
                          });
    
        Evaluator memory evaluator = Evaluator ({
                                  hit_rate: 0,
                                  works_performed: 0,
                                  description: _description,
                                  language: _language,
                                  owner: msg.sender,
                                  balance: balance
                              });
    
        service.evaluators[msg.sender] = evaluator;
    }
    
    function registerBadgeProve(uint _id, string memory _url, string memory _files_hash) public isOwner(_id) {
      require(bytes(_url).length > 0);
      require(bytes(_files_hash).length > 0);
    
      Prove storage prove = proves[_id];
    
      require(bytes(prove.url).length == 0, 'Url already was setup');
      require(bytes(prove.files_hash).length == 0, 'Files hash already was setup');
    
      prove.url = _url;
      prove.files_hash = _files_hash;
    }
    
    modifier isOwner(uint _id) {
       require( badges[_id].owner == msg.sender, "You are not owner of this badge");
       _;
    }

}
