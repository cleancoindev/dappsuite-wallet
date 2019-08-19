@isTest
public class MobileEthereumDashboardControllerTest {
    static testMethod void testAllMethods() {
        
        dapps__NodeSettings__c orgWiseProperty = new dapps__NodeSettings__c();
        orgWiseProperty.Name = 'Properties';
        orgWiseProperty.dapps__Dapps_Key__c = dappsCommonUtils.MASTER_KEY ;
        orgWiseProperty.dapps__Dapps_Server_URL__c= dappsCommonUtils.NODE_URL;
        orgWiseProperty.dapps__Organization_Id__c='';
        orgWiseProperty.dapps__Private_Key__c='01234567890123456789012345678901';
        insert orgWiseProperty;
        
        dapps__Dapps_Config_Settings__c configSettingObj = new dapps__Dapps_Config_Settings__c();
        configSettingObj.Name = 'Properties';
        configSettingObj.dapps__Solidity_Versions_URL__c = dappsCommonUtils.NODE_URL;
        insert configSettingObj;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        dapps__Library__c libObj = new dapps__Library__c();
        libObj.Name = 'Test';
        libObj.dapps__ABI__c = '{}';
        libObj.dapps__Byte_Code__c = 'dffdf';
        insert libObj;
        MobileEthereumDashboardController.getTokens();
        MobileEthereumDashboardController.getTokenTransfers();
        MobileEthereumDashboardController.getAccounts();
        MobileEthereumDashboardController.getAddresses();
        MobileEthereumDashboardController conObj = new MobileEthereumDashboardController();
        conObj.init();
        System.assert(libObj != NULL);
        MobileEthereumDashboardController.sendTransaction('{}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"statusCode":200,"status":"SUCCESS","responseStr":{"keyObj" : {"address":"ADD123"}}}'));
        MobileEthereumDashboardController.createAccount('',null);
        MobileEthereumDashboardController.createAccount('','ABC');
        MobileEthereumDashboardController.createAccount('','ACC311220171635');
        
    }
}