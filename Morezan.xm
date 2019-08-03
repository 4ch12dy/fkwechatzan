
@interface WCDataItem : NSObject

@property (retain, nonatomic) NSMutableArray * likeUsers;

@property  (nonatomic) int likeCount;

@property (retain, nonatomic) NSString* username;

@property (retain, nonatomic) NSMutableArray * commentUsers;

@property  (nonatomic) int commentCount;

@end

@interface SettingUtil : NSObject

+(NSString*) getCurUsrName;

@end

@interface MMServiceCenter : NSObject
+ (instancetype)defaultCenter;
- (id)getService:(Class)service;
@end

@interface CContactMgr : NSObject
- (id)getSelfContact;
- (id)getContactByName:(id)arg1;
- (id)getContactList:(unsigned int)arg1 contactType:(unsigned int)arg2;
- (id)getAllContactUserName;
@end

@interface WCUserComment : NSObject

@property (retain, nonatomic) NSString * nickname;

@property (retain, nonatomic) NSString* username;
@property (retain, nonatomic) NSString* contentPattern;
@property (retain, nonatomic) NSString* content;

@property (retain, nonatomic) NSString* commentID;
@property (retain, nonatomic) NSString* m_cpKeyForComment;//@"wctlcm|33||z314250405||1563794344"   @"wctlcm|99|1|wxid_6913ohfkk7kq12|liuwenling001|1563794437"

@property (retain, nonatomic) NSString* refCommentID;
@property (retain, nonatomic) NSString* refUserName;

@property  (nonatomic) int type; //1 mean like 2 mean comment
@property  (nonatomic) int isRichText; 
@property  (nonatomic) unsigned int createTime; 

@end

@interface CBaseContact : NSObject
@property (nonatomic, copy) NSString *m_nsEncodeUserName;                // 微信用户名转码
@property (nonatomic, assign) int m_uiFriendScene;                       // 是否是自己的好友(非订阅号、自己)
@property (nonatomic,assign) BOOL m_isPlugin;                            // 是否为微信插件
- (BOOL)isChatroom;
@end

@interface CContact : CBaseContact
@property (nonatomic, copy) NSString *m_nsOwner;                        // 拥有者
@property (nonatomic, copy) NSString *m_nsNickName;                     // 用户昵称
@property (nonatomic, copy) NSString *m_nsUsrName;                      // 微信id
@property (nonatomic, copy) NSString *m_nsMemberName;
@end

@interface WCCommentDetailViewControllerFB : NSObject
@property (nonatomic, copy) NSMutableArray *arrLikeList;       
@property (nonatomic, copy) WCDataItem *dataItem; 
@end



NSMutableArray* getFriendList(){
	NSMutableArray* friendList = [NSMutableArray array];
	NSArray* allUserNameArr = [[[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getAllContactUserName] allObjects];
	for(NSString* curUsreName in allUserNameArr){
		CContact* curAddContact = [[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getContactByName:curUsreName];
		if (curAddContact.m_uiFriendScene != 0)
		{
			[friendList addObject:curUsreName];
		}
	}

	return friendList;
} 


NSMutableArray* fkzan(NSMutableArray* origLikeUsers){
	NSMutableArray* newLikeUsers = [NSMutableArray array];
	NSArray* allUserNameArr = [[[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getAllContactUserName] allObjects];
	// uint32_t value = arc4random() % 20;

	// add orig like data
	if ([origLikeUsers count] > 0)
	{
		for(id likeItem in origLikeUsers){
			[newLikeUsers addObject:likeItem];
		}
		
	}

	NSInteger zanCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreZanID"];
	if (!zanCount || zanCount == 0)
	{
		return newLikeUsers;
	}

	// create new fake data: this add 10
	for (int i = 0; i < zanCount; ++i)
	{	
		NSArray* friendArr = getFriendList();
		uint32_t idx = arc4random() % [friendArr count];
		NSString* curAddUserName = [friendArr objectAtIndex:idx];
		CContact* curAddContact = [[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getContactByName:curAddUserName];


		NSString* curAddNickName = [curAddContact m_nsNickName];

		WCUserComment* curAddUserComment = [[%c(WCUserComment) alloc] init];
		curAddUserComment.username = curAddUserName;
		curAddUserComment.nickname = curAddNickName;
		curAddUserComment.type = 1;
		curAddUserComment.isRichText = 1;
		NSTimeInterval interval=[[NSDate date] timeIntervalSince1970];
		NSInteger nowTime = interval;
		curAddUserComment.createTime = nowTime;

		[newLikeUsers addObject:curAddUserComment];
	}

	return newLikeUsers;
}


NSMutableArray* fkCmt(NSMutableArray* origCommentUsers){
	NSMutableArray* newCommentUsers = [NSMutableArray array];
	NSArray* allUserNameArr = [[[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getAllContactUserName] allObjects];
	// uint32_t value = arc4random() % 20;

	// add orig like data
	if ([origCommentUsers count] > 0)
	{
		for(id cmtItem in origCommentUsers){
			[newCommentUsers addObject:cmtItem];
		}
		
	}

	NSInteger cmtCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreCmtID"];
    if (!cmtCount || cmtCount == 0)
    {
        return newCommentUsers;
    }

    NSArray* cmtContent = @[@"高级", @"点赞就完事了", @"6666", @"赞~", @"这个不错",@"什么鬼东西= = ", @"你说的就是这个？" ,@"牛皮", @"来了~~", @"cxk牛b"];

    BOOL isOpenMyCmt = [[NSUserDefaults standardUserDefaults] boolForKey:@"kMoreCmtOpenMyCmt"];
    if (isOpenMyCmt)
    {
    	NSLog(@"xia0:create my comment content.");
        NSString * myCmtContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"kMoreCmtMyCmtContent"];
        cmtContent = [myCmtContent componentsSeparatedByString:@"\n"];
    }

    NSLog(@"xia0:start creat fake cmts");
	// create new fake data: this add 10
	for (int i = 0; i < cmtCount; ++i)
	{	
		// NSLog(@"xia0:debug 1");
		NSArray* friendArr = getFriendList();
		uint32_t idx = arc4random() % [friendArr count];
		NSString* curAddUserName = [friendArr objectAtIndex:idx];
		CContact* curAddContact = [[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getContactByName:curAddUserName];
		
		NSString* curAddNickName = [curAddContact m_nsNickName];
		// NSLog(@"xia0:debug 2");
		WCUserComment* curAddUserComment = [[%c(WCUserComment) alloc] init];
		curAddUserComment.username = curAddUserName;
		curAddUserComment.nickname = curAddNickName;
		curAddUserComment.type = 2;
		curAddUserComment.commentID = [NSString stringWithFormat:@"%d", idx];
		NSTimeInterval interval=[[NSDate date] timeIntervalSince1970];
		NSInteger nowTime = interval;
		curAddUserComment.createTime = nowTime;

		uint32_t cmtContentidx = arc4random() % [cmtContent count];
		NSString* curAddUserCmtContent = [cmtContent objectAtIndex:cmtContentidx];
		curAddUserComment.content = curAddUserCmtContent;
		// curAddUserComment.contentPattern = @"<parser><type>1</type><range>{0, 3}</range></parser>";
		// curAddUserComment.m_cpKeyForComment = [NSString stringWithFormat:@"wctlcm|1||%@||%ld", curAddUserName, nowTime];
		// NSLog(@"xia0:debug 3");
		// NSLog(@"xia0:%@ %@ %d %@ %@ %@ %@", curAddUserName, curAddNickName,curAddUserComment.type, curAddUserComment.commentID, curAddUserComment.content,curAddUserComment.contentPattern,curAddUserComment.m_cpKeyForComment);
		[newCommentUsers addObject:curAddUserComment];
	}

	return newCommentUsers;
}


// more zan in timeline detail
%hook WCCommentDetailViewControllerFB

-(void)setDataItem:(WCDataItem*)dataItem{

	NSMutableArray* origLikeUsers = [dataItem likeUsers];
	NSMutableArray* origCommentUsers = [dataItem commentUsers];

	NSMutableArray* newLikeUsers = fkzan(origLikeUsers);
	NSMutableArray* newCommentUsers = fkCmt(origCommentUsers);

	dataItem.likeUsers = newLikeUsers;
	dataItem.likeCount = [newLikeUsers count];
	dataItem.commentUsers = newCommentUsers;
	dataItem.commentCount = [newCommentUsers count];

	return %orig;
}

%end


// more zan in moment refresh
%hook WCTimelineMgr

- (void)onDataUpdated:(id)arg1 andData:(NSMutableArray*)data andAdData:(id)arg3 withChangedTime:(unsigned int)arg4{
	// [[[MMServiceCenter defaultCenter] getService:[CContactMgr class]] getContactByName:[SettingUtil getCurUsrName]]
	for (WCDataItem* item in data){
		NSString* curUsreName = [item username];
		int likeCount = [item likeCount];
		NSMutableArray* likeUsers = [item likeUsers];
		NSMutableArray* origCommentUsers = [item commentUsers];


		NSString* myName = [%c(SettingUtil) getCurUsrName];

		if ([curUsreName isEqualToString:myName])
		{	
			item.likeUsers = fkzan(likeUsers);
			item.likeCount = [item.likeUsers count];

			NSMutableArray* newCommentUsers = fkCmt(origCommentUsers);
			item.commentUsers = newCommentUsers;
			item.commentCount = [newCommentUsers count];
		}

	}	
	return %orig;
}
%end