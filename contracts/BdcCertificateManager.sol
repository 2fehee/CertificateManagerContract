pragma solidity ^0.5.5;

import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721Metadata.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721MetadataMintable.sol";

contract BdcCertificateManager is
    ERC721,
    ERC721Enumerable,
    ERC721Metadata,
    ERC721MetadataMintable
{
 
    address public manager;
     
    struct certificate {
		address verifierAddress;
        uint256  bID;
        uint256  cID;
		string  grade;
		string  evaluationDate;
		string  evaluationAgency;
		string  certificateHash;
        bool    isLatest;
    }
    
    mapping(uint256 => mapping(uint256 => certificate)) private certificates;
    mapping(uint256 => uint256[]) private certificateList;
     
    modifier onlyOwner {
      require (msg.sender == manager, "ERROR_NOT_OWNER");
      _;
    }

    event CreateCertificate (
        address   indexed owner,
        uint256   _bID,
        uint256   _cID,
        string   _certificateHash
    );

    event DeleteAllCertificate (
        address   indexed owner,
        uint256   _bID
    );
    
    function initialize(
        string memory name,
        string memory symbol
    ) public initializer {
        manager = msg.sender;

        ERC721.initialize();
        ERC721Enumerable.initialize();
        ERC721Metadata.initialize(name, symbol);
        ERC721MetadataMintable.initialize(address(this));
    }
    
    function createBNFT(uint256 _bID, string memory _manufacturerName, string memory _modelName, string memory _manufacturerDate) public returns(string memory){
        require(bytes(_manufacturerName).length > 0 && bytes(_modelName).length > 0 && bytes(_manufacturerDate).length > 0, "ERROR_PARAMETERS");
        string memory _batteryInfoURI = string(abi.encodePacked(_manufacturerName, "_", _modelName, "_", _manufacturerDate));
        _mint(msg.sender, _bID);
        _setTokenURI(_bID, _batteryInfoURI);
        
        return (_batteryInfoURI);
    }
    
    function deleteBNFT(uint256 _bID) public {
        _burn(_bID);
    }
    
    function createCertificate(uint256 _bID, uint256 _cID, string memory _grade, string memory _evaluationDate, string memory _evaluationAgency, string memory _certificateHash) public onlyOwner returns(uint256, uint256){
        require(bytes(_grade).length > 0 && bytes(_evaluationDate).length > 0 && bytes(_evaluationAgency).length > 0 && bytes(_certificateHash).length > 0, "ERROR_PARAMETERS");
        require(certificates[_bID][_cID].verifierAddress == address(0));
		
        certificates[_bID][_cID].verifierAddress = msg.sender;
        certificates[_bID][_cID].bID = _bID;
	    certificates[_bID][_cID].cID = _cID;
		certificates[_bID][_cID].grade = _grade;
		certificates[_bID][_cID].evaluationDate = _evaluationDate;
		certificates[_bID][_cID].evaluationAgency = _evaluationAgency;
		certificates[_bID][_cID].certificateHash = _certificateHash;
        certificates[_bID][_cID].isLatest = true;

        uint nowCertiIndex = getcertificateCount(_bID);

        if(nowCertiIndex > 0)
        {
            uint oldCertiIndex = nowCertiIndex - 1;
            if(certificates[_bID][certificateList[_bID][oldCertiIndex]].isLatest == true)
                certificates[_bID][certificateList[_bID][oldCertiIndex]].isLatest = false;
        }

        certificateList[_bID].push(_cID);

        emit CreateCertificate(msg.sender, _bID, _cID, _certificateHash);
        
        return (_bID, _cID);
    }
    
    function deleteAllCertificate(uint256 _bID) public onlyOwner {
        for(uint i=0;i<certificateList[_bID].length;i++) {
            delete certificates[_bID][certificateList[_bID][i]];
        }
        delete certificateList[_bID];

        emit DeleteAllCertificate(msg.sender, _bID);
    }
    
    function certificateInfo(uint256 _bID, uint256 _cID) public view returns(uint256, uint256, string memory, string memory, string memory, string memory, bool) {
	  require(certificateList[_bID].length > 0);
         
      certificate memory ci = certificates[_bID][_cID];
      return (ci.bID, ci.cID, ci.grade, ci.evaluationDate, ci.evaluationAgency, ci.certificateHash, ci.isLatest);
    }
     
    function checkLatestCertificate(uint256 _bID, uint256 _cID, string memory _certificateHash) public view returns(bool) {
        require(bytes(_certificateHash).length > 0, "ERROR_PARAMETERS");
		if(certificates[_bID][_cID].bID == _bID && certificates[_bID][_cID].cID == _cID && compareStrings(certificates[_bID][_cID].certificateHash, _certificateHash) == true && certificates[_bID][_cID].isLatest == true)
			return true;
			
        return false;
    } 
     
    function checkOldCertificate(uint256 _bID, uint256 _cID, string memory _certificateHash) public view returns(bool) {
        require(bytes(_certificateHash).length > 0, "ERROR_PARAMETERS");
		if(certificates[_bID][_cID].bID == _bID && certificates[_bID][_cID].cID == _cID && compareStrings(certificates[_bID][_cID].certificateHash, _certificateHash) == true)
			return true;
			
        return false;
    }
     
    function getcertificateCount(uint256 _bID) public view returns(uint) {
        return certificateList[_bID].length;
    }
 
    function compareStrings (string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }
    
}