//
//  ProfileViewController.swift
//  Calibrr
//
//  Created by Sayanti on 3/16/18.
//  Copyright © 2018 NCRTS. All rights reserved.
//
/*
 calibrr api key AIzaSyBiCL7-TQ_xCRFKunoA-qhLIWvkf5UOM-s
 client id 149945257280-oi697ij9qgtlaspa8rdkndiuup5l2r1t.apps.googleusercontent.com
 */

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import LinkedinSwift
import NVActivityIndicatorView
import Toast_Swift

class ProfileViewController: UIViewController, UIWebViewDelegate {

    var CustomactivityIndicatorView:NVActivityIndicatorView!
    @IBOutlet weak var tfTwitchUsername: UITextField!
    @IBOutlet weak var vwTransparent: UIView!
    @IBOutlet weak var vwTwitch: UIView!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var viewParent: UIView!
    @IBOutlet var bgTopProfileBackground: UIView!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var imgProfile: UIImageView!
    
    @IBOutlet weak var vwYoutube: UIView!
    @IBOutlet var imgLike: UIImageView!
    @IBOutlet var addsocialmedia: UIButton!
    
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var dobText: UILabel!
  //  @IBOutlet weak var btnGSignIn: GIDSignInButton!
    @IBOutlet var livesInLbl: UILabel!
    @IBOutlet var politicsLbl: UILabel!
    @IBOutlet var religionLbl: UILabel!
    @IBOutlet var educationLbl: UILabel!
    @IBOutlet var occupationLbl: UILabel!
    @IBOutlet var sexualityLbl: UILabel!
    @IBOutlet var relationsLbl: UILabel!
    @IBOutlet var bioLbl: UITextView!
    var dict : [String : AnyObject]!
    var isOwnProfile:Bool = true
    
    // profile details
    var user_id: String!
    var fname: String!
    var lname: String!
    var profile_image: String!
    var location: String!
    var dob: String!
    var bio: String!
    var education: String!
    var politics: String!
    var religion: String!
    var occupation: String!
    var sexuality: String!
    var relationship: String!
    var socialInfo: String!
    var subscription_type: String!
    var device_token: String!
    
    var socialMediaIDs = String()
  //  private let scopes = [kGTLRAuthScopeYouTubeReadonly]
  //  private let service = GTLRYouTubeService()
   // let signInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwTransparent.isHidden = true
        vwTwitch.isHidden = true
        
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
        self.imgProfile.clipsToBounds = true
        
        self.vwTwitch.layer.cornerRadius = 5
        self.vwTwitch.clipsToBounds = true
        
        
        if isOwnProfile == false{
            self.imgProfile.image = UIImage.init(named: "pic-profile-s")
            btnSetting.isHidden = true
        }
        profileViewApi()
    }
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.setNavigationBarHidden(true, animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        switch appDelegate.socialID {
        case "2":
            appDelegate.socialID = ""
            let st = TwitterLoginViewController()
            self.navigationController?.present(st, animated: true, completion: nil)
        case "4":
            appDelegate.socialID = ""
            linkedinSignIn()
        case "7":
            appDelegate.socialID = ""
            vwTransparent.isHidden = false
            vwTwitch.isHidden = false
        case "5":
            appDelegate.socialID = ""
            vwTransparent.isHidden = false
            vwYoutube.isHidden = false
        default:
            return
        }
        
//        if appDelegate.selectedVw == "Twitter" {
//
//
//        }
//        else  if appDelegate.selectedVw == "Linkedin" {
//
//        }
//        else if appDelegate.selectedVw == "Twitch"{
//
//
//
//
//        }
//        else if appDelegate.selectedVw == "Youtube"{
//
//
//
//        }
        
        
    }
    @IBAction func btnYoutubeLoginAction(_ sender: Any) {
        vwTransparent.isHidden = true
        vwYoutube.isHidden = true
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        let searchuser = SearchUserViewController()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func settingBtnAction(_ sender: Any) {
        let editprofile = EditProfileViewController()
        self.navigationController?.pushViewController(editprofile, animated: true)
        
    }
  
   
    @IBAction func twichLoginAction(_ sender: Any) {
        
        vwTransparent.isHidden = true
        vwTwitch.isHidden = true
         twitchApiCall()
    }
    
    @IBAction func addSocialMediabtnAction(_ sender: Any) {
       
        if isOwnProfile == true{
           let st = AddSocialViewController()
           self.navigationController?.present(st, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnYoutubeAction(_ sender: Any) {
        let uthubeVC = YoutubeViewController()
        self.navigationController?.present(uthubeVC, animated: true, completion: nil)
    }
    
    @IBAction func facebookAction(_ sender: Any) {
        let fbVC = FacebookViewController()
        self.navigationController?.present(fbVC, animated: true, completion: nil)
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
//            if (error == nil){
//                let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                if fbloginresult.grantedPermissions != nil {
//                    if(fbloginresult.grantedPermissions.contains("email"))
//                    {
////                        self.feedCheck()
//                        //self.getFBUserData()
//                        self.getFacebookUserPosts()
//                        fbLoginManager.logOut()
//                    }
//                }
//            }
//        }
//    }
//
//    func getFBUserData(){
//
//        if((FBSDKAccessToken.current()) != nil){
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//                if (error == nil){
//                    self.dict = result as! [String : AnyObject]
//                    print(result!)
//                    print(self.dict)
//
//                }
//            })
//        }
    }
            func getFacebookUserPosts() {
                FBSDKGraphRequest(graphPath: "/me/posts", parameters: nil, httpMethod: "GET").start(completionHandler: { (connection, result, error) in
                    if (error == nil){
                        print(result)
                    }
                })
            }
    
    @IBAction func twitterAction(_ sender: Any) {
        
     /*   Twitter.sharedInstance().logInWithCompletion {
            (session, error) -> Void in
            if (session != nil) {
                println("signed in as \(session.userName)");
            } else {
                println("error: \(error.localizedDescription)");
            }
        }*/
        let screenName = "twitterdev" //UserDefaults.standard.string(forKey: "twitterUsername")
        if screenName != "" {
            print("screenName",screenName)
            let nextview = TwitterViewController()
            nextview.screenName = screenName
            self.navigationController?.pushViewController(nextview, animated: true)
        }else{
            Alert.disPlayAlertMessage(titleMessage: "Sorry", alertMsg: "Please add your twitter account")
        }
        
        
      /*  let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nextvc = storyboard.instantiateViewController(withIdentifier: "TwitterLoginViewController")
        self.navigationController?.pushViewController(nextvc, animated: true)*/
    }
    
    @IBAction func linkedinAction(_ sender: Any) {
        
        let nextvc = LinkedInViewController()
        nextvc.strSocial = "linkedin"
       self.navigationController?.pushViewController(nextvc, animated: true)
    }
    @IBAction func instagram(_ sender: Any) {
//       let nextvc = InstagramViewController()
//        self.navigationController?.present(nextvc, animated: true, completion: nil)
    }
    @IBAction func snapChat(_ sender: Any) {
       
//        let nextvc = LinkedInViewController()
//        nextvc.strSocial = "sanpchat"
//        self.navigationController?.pushViewController(nextvc, animated: true)
    }

    @IBAction func otherbtnAction(_ sender: Any){
        
        let search = SearchUserViewController()
        search.page_show_after_navigation = 1
        self.navigationController?.pushViewController(search, animated: true)
        
    }

    @IBAction func btnYTtutorialAction(_ sender: Any) {
        let ytTut = YoutubeTutorialViewController()
        self.navigationController?.pushViewController(ytTut, animated: true)
    }
    
    func profileViewApi()
    {
        let request = ProfileRequest(method: UserDefaults.standard.value(forKey: "user_id") as! String)
        
        RequestExecutor.executeRequest(request, completion: {(error: Error?, Response: ProfileModel?) in
            
            if Response != nil {
               
              
                let fanme = Constants.nullToNil(value: Response?.fname as AnyObject) as? String
                let lname = Constants.nullToNil(value: Response?.lname as AnyObject) as? String
                 self.userNameLbl.text =  fanme! + " " + lname!
                 self.profile_image = Constants.nullToNil(value: Response?.profile_image as AnyObject) as? String
                
                self.livesInLbl.text = Constants.nullToNil(value: Response?.location as AnyObject) as? String
                
                self.dobText.text = Constants.nullToNil(value: Response?.dob as AnyObject) as? String
                
              self.politicsLbl.text = Constants.nullToNil(value: Response?.politics as AnyObject) as? String
                
                self.religionLbl.text = Constants.nullToNil(value: Response?.religion as AnyObject) as? String
                
                self.educationLbl.text = Constants.nullToNil(value: Response?.education as AnyObject) as? String
              
                self.occupationLbl.text = Constants.nullToNil(value: Response?.occupation as AnyObject) as? String
              
                self.sexualityLbl.text = Constants.nullToNil(value: Response?.sexuality as AnyObject) as? String
              
                self.relationsLbl.text = Constants.nullToNil(value: Response?.relationship as AnyObject) as? String
              
               self.socialInfo = Constants.nullToNil(value: Response?.socialInfo as AnyObject) as? String
              

                
            }
            else{
                
                let err = error as? DDSError
                let error_Code = err!.description
                print("error_Code====",error_Code)
                Alert.disPlayAlertMessage(titleMessage: "Sorry", alertMsg: error_Code)
            }
        })
        
        
    }
    
    func linkedinSignIn()
    {
        CustomLoaderShow()
        let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "81ebn8d1oxs6n8", clientSecret: "80g3gbAMZhHpTt70", state: "DLKDJF46ikMMZADfdfds", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "http://127.0.0.1/auth/callback"))
        linkedinHelper.authorizeSuccess({ (token) in
            print("my linkedin token =====>",token)
            
            linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
                
                print("my linked in response ===== > ",response)
                let dictResponse = response.jsonObject
                
                let publicProfUrlString = dictResponse!["publicProfileUrl"] as! String
                print("load profile url =====>>> ",publicProfUrlString)
                self.AddSocialInfoApi(socialuserId: "", socialsiteid: "4" , socialsiteUsername: publicProfUrlString)
                
                //parse this response which is in the JSON format
            }) {(error) -> Void in
                
                print(error.localizedDescription)
                //handle the error
            }
            
            
            //////////////////////////////////////////////////////////////////
            /* linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,public-profile-url,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location)?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
             
             print("my linked in response ===== > ",response)
             let dictResponse = response.jsonObject
             var dictUrl = [String : String]()
             dictUrl = dictResponse!["siteStandardProfileRequest"] as! [String : String]
             print("load profile url =====>>> ",dictUrl["url"]!)
             
             let urlRQST = URLRequest(url: URL(string: dictUrl["url"]!)!)
             self.webVwLinkedin.loadRequest(urlRQST)
             self.webVwLinkedin.isHidden = false
             self.viewParent.bringSubview(toFront: self.webVwLinkedin)
             //parse this response which is in the JSON format
             }) {(error) -> Void in
             
             print(error.localizedDescription)
             //handle the error
             }*/
            //////////////////////////////////////////////////////////////////
            
            
            
        }, error: { (error) in
            
            print(error.localizedDescription)
            //show respective error
        }) {
            //show sign in cancelled event
        }
    }
    func twitchApiCall()  {
        
       self.CustomLoaderShow()
        let user = tfTwitchUsername.text!
        let strUrl = "https://api.twitch.tv/kraken/users/" + user + "?" + "client_id=30pqvtzqyxad5qvjlxbxc674kesrdv"
        
        print("strUrl--",strUrl)
        var request = URLRequest(url: URL(string:strUrl)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            print("Entered the completionHandler")
            
            if err != nil {
                print(err ?? "None")
            }
            else {
                do{
                    // let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    
                    OperationQueue.main.addOperation({
                        self.CustomLoaderHide()
                        print("Json---",json)
                       
                        if json["error"] == nil {
                            let name = json["name"] as! String
                            let str = "https://www.twitch.tv/" + name
                            print("public profile url===> ",str)
                        }
                        else{
                            print(json)
                            self.view.makeToast("Sorry invalid twitch user ", duration: 3.0, position: .bottom)
                            self.CustomLoaderHide()
                        }
                        
                    })
                    
                }catch let error as NSError{
                    print(error)
                }
                
            }
           
            }.resume()
    }
    
    func CustomLoaderShow()
    {
        
        let Loaderframe = CGRect(x: CGFloat((UIScreen.main.bounds.size.width - 50) / 2), y: CGFloat((self.view.frame.size.height - 50) / 2), width: 50, height: 50)
        CustomactivityIndicatorView = NVActivityIndicatorView(frame: Loaderframe,type: NVActivityIndicatorType .ballClipRotate)
        CustomactivityIndicatorView.color = UIColor(red: 56.0/255.0, green: 160.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        self.view.addSubview(CustomactivityIndicatorView)
        CustomactivityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled=false
        
    }
    func CustomLoaderHide()
    {
        CustomactivityIndicatorView.stopAnimating()
        self.view.isUserInteractionEnabled=true
    }
    
    func AddSocialInfoApi(socialuserId : String, socialsiteid : String, socialsiteUsername : String )
    {
        let request = AddSocialInfoRequest(userId: UserDefaults.standard.value(forKey: "user_id") as! String, social_userId: socialuserId, social_site_id: socialsiteid, social_siteUsername: socialsiteUsername)
        
        RequestExecutor.executeRequest(request, completion: {(error: Error?, Response: AddSocialInfoModel?) in
            
            if Response != nil {
                self.CustomLoaderHide()
            }
            else{
                self.CustomLoaderHide()
                let err = error as? DDSError
                let error_Code = err!.description
                print("error_Code====",error_Code)
                Alert.disPlayAlertMessage(titleMessage: "Sorry", alertMsg: error_Code)
            }
        })
    }
   /* func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("Authentication Error ",error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchUser()
        }
    }
    func fetchUser()
    {
        let urlstr = "https://www.googleapis.com/youtube/v3/channelSections/?part=snippet%2CcontentDetails&mine=true"
        print(urlstr)
        let myurl = URL(string : urlstr)
        let mysession = URLSession.shared
        let mytask = mysession.dataTask(with: myurl!) { (data, response, error) in
            if error != nil
            {
                print(error!)
            }
            else
            {
                do {
                    let jsondata = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    print(jsondata)
                    
                }
                catch let err{
                    print(err)
                }
            }
        }
        mytask.resume()
    }*/
    
    

//    func fetchChannelResource() {
//        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet,statistics")
//        query.identifier = "UC_x5XG1OV2P6uZZ5FSM9Ttw"
//        // To retrieve data for the current user's channel, comment out the previous
//        // line (query.identifier ...) and uncomment the next line (query.mine ...)
//        // query.mine = true
//        service.executeQuery(query,
//                             delegate: self,
//                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
//    }
//    func displayResultWithTicket(
//        ticket: GTLRServiceTicket,
//        finishedWithObject response : GTLRYouTube_ChannelListResponse,
//        error : NSError?) {
//
//        if let error = error {
//            print("Error",error.localizedDescription)
//            return
//        }
//
//        var outputText = ""
//        if let channels = response.items, !channels.isEmpty {
//            let channel = response.items![0]
//            let title = channel.snippet!.title
//            let description = channel.snippet?.descriptionProperty
//            let viewCount = channel.statistics?.viewCount
//            outputText += "title: \(title!)\n"
//            outputText += "description: \(description!)\n"
//            outputText += "view count: \(viewCount!)\n"
//        }
//        print("output text = ", outputText)
//    }
   
    
}
