//
//  ModelContact.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@interface ModelContact : BaseDataModel

@property NSString *address;
//@property NSString *address;
//@property NSString *address;
//@property NSString *address;

@property NSString *fullName;
@property NSString *email;
@property NSString *contactId;
@property NSString *urlPhoto;

@property NSString *lastUpdate;

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName contactId:(NSString *)contactId urlPhoto:(NSString *)urlPhoto;

@end


//GetContacts JSON: {
//    encoding = "UTF-8";
//    feed =     {
//        author =         (
//                          {
//                              email =                 {
//                                  "$t" = "ghukasyangevorg1@gmail.com";
//                              };
//                              name =                 {
//                                  "$t" = "Gevorg Ghukasyan";
//                              };
//                          }
//                          );
//        category =         (
//                            {
//                                scheme = "http://schemas.google.com/g/2005#kind";
//                                term = "http://schemas.google.com/contact/2008#contact";
//                            }
//                            );
//        entry =         (
//                         {
//                             "app$edited" =                 {
//                                 "$t" = "2015-05-22T16:41:48.400Z";
//                                 "xmlns$app" = "http://www.w3.org/2007/app";
//                             };
//                             category =                 (
//                                                         {
//                                                             scheme = "http://schemas.google.com/g/2005#kind";
//                                                             term = "http://schemas.google.com/contact/2008#contact";
//                                                         }
//                                                         );
//                             "gd$email" =                 (
//                                                           {
//                                                               address = "amkrtchian@science-inc.com";
//                                                               primary = true;
//                                                               rel = "http://schemas.google.com/g/2005#other";
//                                                           }
//                                                           );
//                             "gd$etag" = "\"SXo7eDVSLyt7I2A9XRVRE0wITgQ.\"";
//                             "gd$name" =                 {
//                                 "gd$familyName" =                     {
//                                     "$t" = Mkrtchian;
//                                 };
//                                 "gd$fullName" =                     {
//                                     "$t" = "Armen Mkrtchian";
//                                 };
//                                 "gd$givenName" =                     {
//                                     "$t" = Armen;
//                                 };
//                             };
//                             id =                 {
//                                 "$t" = "http://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/base/22e8cb048eb02b66";
//                             };
//                             link =                 (
//                                                     {
//                                                         href = "https://www.google.com/m8/feeds/photos/media/ghukasyangevorg1%40gmail.com/22e8cb048eb02b66";
//                                                         rel = "http://schemas.google.com/contacts/2008/rel#photo";
//                                                         type = "image/*";
//                                                     },
//                                                     {
//                                                         href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full/22e8cb048eb02b66";
//                                                         rel = self;
//                                                         type = "application/atom+xml";
//                                                     },
//                                                     {
//                                                         href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full/22e8cb048eb02b66";
//                                                         rel = edit;
//                                                         type = "application/atom+xml";
//                                                     }
//                                                     );
//                             title =                 {
//                                 "$t" = "Armen Mkrtchian";
//                             };
//                             updated =                 {
//                                 "$t" = "2015-05-22T16:41:48.400Z";
//                             };
//                         },
//                         {
//                             "app$edited" =                 {
//                                 "$t" = "2015-07-08T09:35:31.784Z";
//                                 "xmlns$app" = "http://www.w3.org/2007/app";
//                             };
//                             category =                 (
//                                                         {
//                                                             scheme = "http://schemas.google.com/g/2005#kind";
//                                                             term = "http://schemas.google.com/contact/2008#contact";
//                                                         }
//                                                         );
//                             "gd$email" =                 (
//                                                           {
//                                                               address = "gevorgghukasyan@yahoo.com";
//                                                               primary = true;
//                                                               rel = "http://schemas.google.com/g/2005#other";
//                                                           }
//                                                           );
//                             "gd$etag" = "\"QHkzfDVSLit7I2A9XRVVE0kCRgc.\"";
//                             id =                 {
//                                 "$t" = "http://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/base/27889b8b8c8ed69e";
//                             };
//                             link =                 (
//                                                     {
//                                                         href = "https://www.google.com/m8/feeds/photos/media/ghukasyangevorg1%40gmail.com/27889b8b8c8ed69e";
//                                                         rel = "http://schemas.google.com/contacts/2008/rel#photo";
//                                                         type = "image/*";
//                                                     },
//                                                     {
//                                                         href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full/27889b8b8c8ed69e";
//                                                         rel = self;
//                                                         type = "application/atom+xml";
//                                                     },
//                                                     {
//                                                         href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full/27889b8b8c8ed69e";
//                                                         rel = edit;
//                                                         type = "application/atom+xml";
//                                                     }
//                                                     );
//                             title =                 {
//                                 "$t" = "";
//                             };
//                             updated =                 {
//                                 "$t" = "2015-07-08T09:35:31.784Z";
//                             };
//                         }
//                         );
//        "gd$etag" = "\"SX0yfTVSLyt7I2A9XRVVFU8PQwA.\"";
//        generator =         {
//            "$t" = Contacts;
//            uri = "http://www.google.com/m8/feeds";
//            version = "1.0";
//        };
//        id =         {
//            "$t" = "ghukasyangevorg1@gmail.com";
//        };
//        link =         (
//                        {
//                            href = "https://www.google.com/";
//                            rel = alternate;
//                            type = "text/html";
//                        },
//                        {
//                            href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full";
//                            rel = "http://schemas.google.com/g/2005#feed";
//                            type = "application/atom+xml";
//                        },
//                        {
//                            href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full";
//                            rel = "http://schemas.google.com/g/2005#post";
//                            type = "application/atom+xml";
//                        },
//                        {
//                            href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full/batch";
//                            rel = "http://schemas.google.com/g/2005#batch";
//                            type = "application/atom+xml";
//                        },
//                        {
//                            href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full?max-results=2&start-index=2&alt=json";
//                            rel = self;
//                            type = "application/atom+xml";
//                        },
//                        {
//                            href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full?max-results=2&start-index=1&alt=json";
//                            rel = previous;
//                            type = "application/atom+xml";
//                        },
//                        {
//                            href = "https://www.google.com/m8/feeds/contacts/ghukasyangevorg1%40gmail.com/full?max-results=2&start-index=4&alt=json";
//                            rel = next;
//                            type = "application/atom+xml";
//                        }
//                        );
//        "openSearch$itemsPerPage" =         {
//            "$t" = 2;
//        };
//        "openSearch$startIndex" =         {
//            "$t" = 2;
//        };
//        "openSearch$totalResults" =         {
//            "$t" = 8;
//        };
//        title =         {
//            "$t" = "Gevorg Ghukasyan's Contacts";
//        };
//        updated =         {
//            "$t" = "2015-07-10T10:50:48.395Z";
//        };
//        xmlns = "http://www.w3.org/2005/Atom";
//        "xmlns$batch" = "http://schemas.google.com/gdata/batch";
//        "xmlns$gContact" = "http://schemas.google.com/contact/2008";
//        "xmlns$gd" = "http://schemas.google.com/g/2005";
//        "xmlns$openSearch" = "http://a9.com/-/spec/opensearch/1.1/";
//    };
//    version = "1.0";
//}