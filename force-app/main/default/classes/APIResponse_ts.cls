/**
 * @description APIResponse 단위 테스트
 */
@IsTest
private class APIResponse_ts {

    /**
     * @description Builder로 성공 응답 생성 테스트
     */
    @IsTest
    static void testBuildSuccessResponse() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When
            APIResponse kResponse = new APIResponse.Builder()
                .success(true)
                .requestUrl('/api/v1.0/users')
                .build();

            // Then
            Assert.areEqual(true, kResponse.success, '성공 여부가 true여야 함');
            Assert.areEqual('/api/v1.0/users', kResponse.requestUrl, '요청 URL이 설정되어야 함');
            Assert.isNotNull(kResponse.timestamp, 'timestamp가 자동 생성되어야 함');
            Assert.isNull(kResponse.error, '성공 응답은 error가 null이어야 함');
        }
    }

    /**
     * @description Builder로 에러 응답 생성 테스트
     */
    @IsTest
    static void testBuildErrorResponse() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When
            APIResponse kResponse = new APIResponse.Builder()
                .success(false)
                .requestUrl('/api/v1.0/users')
                .error('ValidationError', 'Invalid user data')
                .build();

            // Then
            Assert.areEqual(false, kResponse.success, '성공 여부가 false여야 함');
            Assert.areEqual('/api/v1.0/users', kResponse.requestUrl, '요청 URL이 설정되어야 함');
            Assert.isNotNull(kResponse.error, '에러 정보가 있어야 함');
            Assert.areEqual('ValidationError', kResponse.error.type, '에러 타입이 설정되어야 함');
            Assert.areEqual('Invalid user data', kResponse.error.message, '에러 메시지가 설정되어야 함');
        }
    }

    /**
     * @description timestamp 자동 설정 테스트
     */
    @IsTest
    static void testTimestampAutoGeneration() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            Datetime kBeforeTime = Datetime.now();

            // When
            APIResponse kResponse = new APIResponse.Builder()
                .success(true)
                .requestUrl('/api/v1.0/test')
                .build();

            // Then
            Assert.isNotNull(kResponse.timestamp, 'timestamp가 자동 생성되어야 함');
            Assert.isTrue(kResponse.timestamp.contains('T'), 'ISO 8601 형식이어야 함');
            Assert.isTrue(kResponse.timestamp.contains('Z'), 'UTC 표시가 있어야 함');
        }
    }

    /**
     * @description 사용자 정의 timestamp 설정 테스트
     */
    @IsTest
    static void testCustomTimestamp() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            String kCustomTimestamp = '2025-01-01T00:00:00Z';

            // When
            APIResponse kResponse = new APIResponse.Builder()
                .success(true)
                .requestUrl('/api/v1.0/test')
                .timestamp(kCustomTimestamp)
                .build();

            // Then
            Assert.areEqual(kCustomTimestamp, kResponse.timestamp, '사용자 정의 timestamp가 설정되어야 함');
        }
    }

    /**
     * @description 모든 필드 설정 테스트
     */
    @IsTest
    static void testAllFieldsSet() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            String kTimestamp = '2025-10-24T10:30:00Z';

            // When
            APIResponse kResponse = new APIResponse.Builder()
                .success(false)
                .requestUrl('/api/v1.0/orders/123')
                .timestamp(kTimestamp)
                .error('NotFoundError', 'Order not found')
                .build();

            // Then
            Assert.areEqual(false, kResponse.success, 'success가 설정되어야 함');
            Assert.areEqual('/api/v1.0/orders/123', kResponse.requestUrl, 'requestUrl이 설정되어야 함');
            Assert.areEqual(kTimestamp, kResponse.timestamp, 'timestamp가 설정되어야 함');
            Assert.isNotNull(kResponse.error, 'error가 설정되어야 함');
            Assert.areEqual('NotFoundError', kResponse.error.type, 'error type이 설정되어야 함');
            Assert.areEqual('Order not found', kResponse.error.message, 'error message가 설정되어야 함');
        }
    }

    /**
     * @description 최소 필드만 설정 테스트
     */
    @IsTest
    static void testMinimalFieldsSet() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When
            APIResponse kResponse = new APIResponse.Builder()
                .success(true)
                .build();

            // Then
            Assert.areEqual(true, kResponse.success, 'success가 설정되어야 함');
            Assert.isNull(kResponse.requestUrl, 'requestUrl이 null이어야 함');
            Assert.isNotNull(kResponse.timestamp, 'timestamp는 자동 생성되어야 함');
            Assert.isNull(kResponse.error, 'error가 null이어야 함');
        }
    }

    /**
     * @description APIError 직접 생성 테스트
     */
    @IsTest
    static void testAPIErrorCreation() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When
            APIResponse.APIError kError = new APIResponse.APIError('TestError', 'Test message');

            // Then
            Assert.areEqual('TestError', kError.type, 'error type이 설정되어야 함');
            Assert.areEqual('Test message', kError.message, 'error message가 설정되어야 함');
        }
    }

    /**
     * @description JSON 직렬화 테스트
     */
    @IsTest
    static void testJSONSerialization() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            APIResponse kResponse = new APIResponse.Builder()
                .success(true)
                .requestUrl('/api/v1.0/test')
                .build();

            // When
            String kJson = JSON.serialize(kResponse);

            // Then
            Assert.isNotNull(kJson, 'JSON이 생성되어야 함');
            Assert.isTrue(kJson.contains('"success":true'), 'success 필드가 포함되어야 함');
            Assert.isTrue(kJson.contains('"requestUrl":"/api/v1.0/test"'), 'requestUrl 필드가 포함되어야 함');
            Assert.isTrue(kJson.contains('"timestamp"'), 'timestamp 필드가 포함되어야 함');
        }
    }

    /**
     * @description 에러 응답 JSON 직렬화 테스트
     */
    @IsTest
    static void testErrorResponseJSONSerialization() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            APIResponse kResponse = new APIResponse.Builder()
                .success(false)
                .requestUrl('/api/v1.0/test')
                .error('TestError', 'Test error message')
                .build();

            // When
            String kJson = JSON.serialize(kResponse);

            // Then
            Assert.isNotNull(kJson, 'JSON이 생성되어야 함');
            Assert.isTrue(kJson.contains('"success":false'), 'success가 false여야 함');
            Assert.isTrue(kJson.contains('"error"'), 'error 필드가 포함되어야 함');
            Assert.isTrue(kJson.contains('"type":"TestError"'), 'error type이 포함되어야 함');
            Assert.isTrue(kJson.contains('"message":"Test error message"'), 'error message가 포함되어야 함');
        }
    }

    /**
     * @description Builder 메서드 체이닝 테스트
     */
    @IsTest
    static void testBuilderMethodChaining() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When - 메서드 체이닝으로 모든 필드 설정
            APIResponse kResponse = new APIResponse.Builder()
                .success(true)
                .requestUrl('/api/v1.0/chaining')
                .timestamp('2025-10-24T12:00:00Z')
                .build();

            // Then
            Assert.isNotNull(kResponse, 'Response가 생성되어야 함');
            Assert.areEqual(true, kResponse.success, 'success가 설정되어야 함');
            Assert.areEqual('/api/v1.0/chaining', kResponse.requestUrl, 'requestUrl이 설정되어야 함');
            Assert.areEqual('2025-10-24T12:00:00Z', kResponse.timestamp, 'timestamp가 설정되어야 함');
        }
    }
}
