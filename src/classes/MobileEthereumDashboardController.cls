public with sharing class MobileEthereumDashboardController {
    
    
    public String solidityVersionsUrl{get;set;}
    
    public void init(){
        
        dapps__Dapps_Config_Settings__c configSettingObj = null;
        try{
            configSettingObj = DappsServices.getConfig('Properties',new List<String>{'Name', 'dapps__Solidity_Versions_URL__c'});            
        }catch(Exception e){
            //No Read Access
        }    
        //dapps__Dapps_Config_Settings__c configSettingObj = dapps__Dapps_Config_Settings__c.getValues('Properties');
        if(configSettingObj!=null){
            solidityVersionsUrl = configSettingObj.dapps__Solidity_Versions_URL__c;
        }
        
    }
    
    @RemoteAction
    public static String sendTransaction(String reqMapStr){
        system.debug('***inside onclickapex call***reqMapStr:'+reqMapStr);        
        return HttpUtils.submitRequestWithMethod(reqMapStr, 'sendTransactionSign2');
    }
    
    
    @RemoteAction
    public static List<dapps__Address__c> getAddresses(){
        SecurityUtils.checkSecurity('dapps__Address__c',  new List<String>{'id', 'Name', 'dapps__Name__c', 'dapps__Account__c', 'dapps__Is_Primary__c'});
        List<dapps__Address__c> addresses = [select id, Name, dapps__Name__c, dapps__Account__c, dapps__Is_Primary__c from dapps__Address__c where dapps__Is_Primary__c = true];
        return addresses;
    }    
    
    @RemoteAction
    public static List<dapps__Token__c> getTokens(){
        SecurityUtils.checkSecurity('dapps__Token__c',  new List<String>{'id','name','dapps__Contract_Address__c','dapps__Smart_Contract__c','dapps__Total_Supply__c', 'dapps__Tokens_Issued_Display__c', 'dapps__Symbol__c'});
        List<dapps__Token__c> tokens = [select id, dapps__Contract_Address__c, dapps__Smart_Contract__r.name, dapps__Smart_Contract__r.dapps__Library__r.dapps__ABI__c, dapps__Smart_Contract__r.dapps__Library__r.dapps__Byte_Code__c, dapps__Total_Supply__c, dapps__Tokens_Issued_Display__c, dapps__Symbol__c, name from dapps__Token__c where dapps__IsActive__c = true];
        return tokens;
    }    
    
    @RemoteAction
    public static List<dapps__Token_Transfers__c> getTokenTransfers(){
        SecurityUtils.checkSecurity('dapps__Token_Transfers__c', new List<String>{'id', 'dapps__Contact_Name__c', 'dapps__Token_Name__c', 'name', 'dapps__Transaction_Hash__c', 'dapps__Age__c', 'dapps__Block_Height__c', 'dapps__From_Address__c', 'dapps__To_Address__c', 'dapps__Symbol__c', 'dapps__Value_Display__c'});
        List<dapps__Token_Transfers__c> tokenTransfers = [select id, dapps__Token_Name__c, dapps__Contact_Name__c, dapps__Age__c, dapps__Block_Height__c, dapps__Transaction_Hash__c, dapps__From_Address__c, dapps__To_Address__c, dapps__Symbol__c, dapps__Value_Display__c, name from dapps__Token_Transfers__c ORDER BY dapps__Age__c ASC LIMIT 20];
        return tokenTransfers;
    }
    
    
    
     @RemoteAction
    public static List<dapps__KeySettings__c> getAccounts(){
        List<dapps__KeySettings__c> accounts = null;
        try{
            accounts = DappsServices.getKeys(new List<String>{'Name', 'dapps__Address__c'});            
        }catch(Exception e){
            accounts = new List<dapps__KeySettings__c>();
        }
        return accounts;
        //List<dapps__KeySettings__c> acounts = dapps__KeySettings__c.getall().values();
        //return acounts;
    }
    
        @RemoteAction
    public static String createAccount(String reqMapStr,String name){
        if(name == null || name == ''){
            name = 'Account_' + DateTime.now().millisecond();
        }
        //system.debug('***inside onclickapex call***reqMapStr:'+reqMapStr);
        CommonResponse commonResponseObj = null;
        List<dapps__KeySettings__c> accounts = DappsServices.getKeys(new List<String>{'Name', 'dapps__Address__c'});           
        for(dapps__KeySettings__c account : accounts){
            if(account.Name == name){
                commonResponseObj = new CommonResponse();
                commonResponseObj.status = 'ERROR';
                commonResponseObj.statusCode = 500;
                commonResponseObj.responseStr = '{"message" : "Account with Name '+name+' already exists."}';
                return JSON.serialize(commonResponseObj);
            }
        }
        
        String accountJSONStr =  HttpUtils.submitRequestWithMethod(reqMapStr, 'createAccount2');
        
        try{
            System.debug('accountJSONStr:'+accountJSONStr);
            commonResponseObj = (CommonResponse)JSON.deserialize(accountJSONStr, CommonResponse.class);
        }catch(Exception e){
            commonResponseObj = new CommonResponse();
            commonResponseObj.status = 'ERROR';
            commonResponseObj.statusCode = 500;
            commonResponseObj.responseStr = 'Problem occured.';
            return JSON.serialize(commonResponseObj);
        }
        
        if(commonResponseObj.statusCode == 500){
            return accountJSONStr;
        }
        AccountCreateResponse accResponse = (AccountCreateResponse)JSON.deserialize(commonResponseObj.responseStr, AccountCreateResponse.class);
        System.debug('accResponse:'+accResponse);
        dapps__KeySettings__c keyRecord = new dapps__KeySettings__c();
        keyRecord.Name = name;
        if(accResponse!=null){
            keyRecord.dapps__Address__c = accResponse.keyObj.address;
        }
        System.debug('keyRecord:'+keyRecord);
        try{
            DappsServices.insertKey(keyRecord, new List<String>{'Name','dapps__Address__c'});
        }catch(Exception e){
            System.debug('Error while inserting Key Object due to security reason.');
        }
        //insert keyRecord;
        //if(accResponse!=null){
        //    return accResponse.keyObj.address;
        //}
        return accountJSONStr;
    }

}