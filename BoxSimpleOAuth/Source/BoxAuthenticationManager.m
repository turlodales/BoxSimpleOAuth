//Copyright (c) 2016 Ryan Baumbach <github@ryan.codes>
//
//Permission is hereby granted, free of charge, to any person obtaining
//a copy of this software and associated documentation files (the "Software"),
//to deal in the Software without restriction, including
//without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to
//permit persons to whom the Software is furnished to do so, subject to
//the following conditions:
//
//The above copyright notice and this permission notice shall be
//included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <SimpleOAuth2/SimpleOAuth2.h>
#import "BoxAuthenticationManager.h"
#import "BoxLoginResponse.h"
#import "BoxConstants.h"
#import "BoxTokenParameters.h"
#import "BoxRefreshTokenParameters.h"


NSString *const BoxTokenEndpoint = @"/api/oauth2/token";

@interface BoxAuthenticationManager ()

@property (copy, nonatomic) NSString *clientID;
@property (copy, nonatomic) NSString *clientSecret;
@property (copy, nonatomic) NSString *callbackURLString;
@property (strong, nonatomic) SimpleOAuth2AuthenticationManager *simpleOAuth2AuthenticationManager;

@end

@implementation BoxAuthenticationManager

#pragma mark - Init Methods

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret
               callbackURLString:(NSString *)callbackURLString
{
    self = [super init];
    if (self) {
        self.clientID = clientID;
        self.clientSecret = clientSecret;
        self.callbackURLString = callbackURLString;
        self.simpleOAuth2AuthenticationManager = [[SimpleOAuth2AuthenticationManager alloc] init];
    }
    return self;
}

#pragma mark - Public Methods

- (void)authenticateClientWithAuthCode:(NSString *)authCode
                               success:(void (^)(BoxLoginResponse *response))success
                               failure:(void (^)(NSError *error))failure
{
    [self.simpleOAuth2AuthenticationManager authenticateOAuthClient:[self authenticationURLString]
                                                    tokenParameters:[self boxTokenParametersFromAuthCode:authCode]
                                                            success:^(id authResponseObject) {
                                                                BoxLoginResponse *loginResponse = [[BoxLoginResponse alloc] initWithBoxOAuthResponse:authResponseObject];
                                                                success(loginResponse);
                                                            } failure:failure];
}

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken
                                   success:(void (^)(BoxLoginResponse *response))success
                                   failure:(void (^)(NSError *error))failure
{
    [self.simpleOAuth2AuthenticationManager authenticateOAuthClient:[self authenticationURLString]
                                                    tokenParameters:[self boxRefreshTokenParametersFromRefreshToken:refreshToken]
                                                            success:^(id authResponseObject) {
                                                                BoxLoginResponse *loginResponse = [[BoxLoginResponse alloc] initWithBoxOAuthResponse:authResponseObject];
                                                                success(loginResponse);
                                                            } failure:failure];
}

#pragma mark - Private Methods

- (id<TokenParameters>)boxTokenParametersFromAuthCode:(NSString *)authCode
{
    BoxTokenParameters *boxTokenParameters = [[BoxTokenParameters alloc] init];
    boxTokenParameters.clientID = self.clientID;
    boxTokenParameters.clientSecret = self.clientSecret;
    boxTokenParameters.callbackURLString = self.callbackURLString;
    boxTokenParameters.authorizationCode = authCode;

    return boxTokenParameters;
}

- (id<TokenParameters>)boxRefreshTokenParametersFromRefreshToken:(NSString *)refreshToken
{
    BoxRefreshTokenParameters *boxRefreshTokenParameters = [[BoxRefreshTokenParameters alloc] init];
    boxRefreshTokenParameters.clientID = self.clientID;
    boxRefreshTokenParameters.clientSecret = self.clientSecret;
    boxRefreshTokenParameters.refreshToken = refreshToken;

    return boxRefreshTokenParameters;
}

- (NSURL *)authenticationURLString
{
    NSString *authenticationURLString = [NSString stringWithFormat:@"%@%@", BoxAuthURL, BoxTokenEndpoint];

    return [NSURL URLWithString:authenticationURLString];
}

@end
