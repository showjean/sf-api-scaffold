/**
 * @description APIContext 단위 테스트
 */
@IsTest
private class APIContext_ts {

    /**
     * @description 테스트용 더미 APIProcessor 구현체
     */
    private class DummyProcessor implements APIProcessor {
        public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
            // 더미 구현
        }
    }

    /**
     * @description Builder로 기본 APIContext 생성 테스트
     */
    @IsTest
    static void testBuildBasicContext() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When
            APIContext kContext = new APIContext.Builder()
                .pattern('/api/v1.0/users')
                .requestUrl('/api/v1.0/users/123')
                .httpMethod('GET')
                .build();

            // Then
            Assert.areEqual('/api/v1.0/users', kContext.pattern, 'pattern이 설정되어야 함');
            Assert.areEqual('/api/v1.0/users/123', kContext.requestUrl, 'requestUrl이 설정되어야 함');
            Assert.areEqual('GET', kContext.httpMethod, 'httpMethod가 설정되어야 함');
            Assert.isNull(kContext.processor, 'processor가 null이어야 함');
            Assert.isNotNull(kContext.pathVar, 'pathVar가 초기화되어야 함');
            Assert.areEqual(0, kContext.pathVar.size(), 'pathVar가 빈 Map이어야 함');
        }
    }

    /**
     * @description Builder로 모든 필드 설정 테스트
     */
    @IsTest
    static void testBuildAllFields() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DummyProcessor kProcessor = new DummyProcessor();
            Map<String, String> kPathVar = new Map<String, String>{
                'userId' => '123',
                'orderId' => '456'
            };

            // When
            APIContext kContext = new APIContext.Builder()
                .pattern('/api/users/:userId/orders/:orderId')
                .requestUrl('/api/users/123/orders/456')
                .httpMethod('POST')
                .processor(kProcessor)
                .pathVar(kPathVar)
                .build();

            // Then
            Assert.areEqual('/api/users/:userId/orders/:orderId', kContext.pattern, 'pattern이 설정되어야 함');
            Assert.areEqual('/api/users/123/orders/456', kContext.requestUrl, 'requestUrl이 설정되어야 함');
            Assert.areEqual('POST', kContext.httpMethod, 'httpMethod가 설정되어야 함');
            Assert.isNotNull(kContext.processor, 'processor가 설정되어야 함');
            Assert.areEqual(2, kContext.pathVar.size(), 'pathVar에 2개의 변수가 있어야 함');
            Assert.areEqual('123', kContext.pathVar.get('userId'), 'userId가 설정되어야 함');
            Assert.areEqual('456', kContext.pathVar.get('orderId'), 'orderId가 설정되어야 함');
        }
    }

    /**
     * @description 복사 생성자 테스트
     */
    @IsTest
    static void testCopyConstructor() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 원본 APIContext 생성
            DummyProcessor kProcessor = new DummyProcessor();
            Map<String, String> kPathVar = new Map<String, String>{
                'id' => '123'
            };

            APIContext kOriginal = new APIContext.Builder()
                .pattern('/api/users/:id')
                .requestUrl('/api/users/123')
                .httpMethod('GET')
                .processor(kProcessor)
                .pathVar(kPathVar)
                .build();

            // When - 복사 생성자로 새 APIContext 생성
            APIContext kCopy = new APIContext.Builder(kOriginal)
                .build();

            // Then - 모든 필드가 복사되어야 함
            Assert.areEqual(kOriginal.pattern, kCopy.pattern, 'pattern이 복사되어야 함');
            Assert.areEqual(kOriginal.requestUrl, kCopy.requestUrl, 'requestUrl이 복사되어야 함');
            Assert.areEqual(kOriginal.httpMethod, kCopy.httpMethod, 'httpMethod가 복사되어야 함');
            Assert.areEqual(kOriginal.processor, kCopy.processor, 'processor가 복사되어야 함');
            Assert.areEqual(kOriginal.pathVar.size(), kCopy.pathVar.size(), 'pathVar 크기가 같아야 함');
            Assert.areEqual(kOriginal.pathVar.get('id'), kCopy.pathVar.get('id'), 'pathVar 값이 복사되어야 함');
        }
    }

    /**
     * @description 복사 후 일부 필드 수정 테스트
     */
    @IsTest
    static void testCopyAndModify() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 원본 APIContext
            APIContext kOriginal = new APIContext.Builder()
                .pattern('/api/users')
                .requestUrl('/api/users/123')
                .httpMethod('GET')
                .build();

            // When - 복사 후 일부 필드 수정
            DummyProcessor kNewProcessor = new DummyProcessor();
            APIContext kModified = new APIContext.Builder(kOriginal)
                .processor(kNewProcessor)
                .httpMethod('POST')
                .build();

            // Then - 수정된 필드만 변경되어야 함
            Assert.areEqual(kOriginal.pattern, kModified.pattern, 'pattern은 유지되어야 함');
            Assert.areEqual(kOriginal.requestUrl, kModified.requestUrl, 'requestUrl은 유지되어야 함');
            Assert.areEqual('POST', kModified.httpMethod, 'httpMethod는 수정되어야 함');
            Assert.isNotNull(kModified.processor, 'processor가 설정되어야 함');
            Assert.isNull(kOriginal.processor, '원본 processor는 null이어야 함');
        }
    }

    /**
     * @description pathVar Map 설정 테스트
     */
    @IsTest
    static void testPathVarSetting() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            Map<String, String> kPathVar = new Map<String, String>{
                'version' => 'v1.0',
                'resource' => 'users',
                'id' => '123'
            };

            // When
            APIContext kContext = new APIContext.Builder()
                .pathVar(kPathVar)
                .build();

            // Then
            Assert.areEqual(3, kContext.pathVar.size(), 'pathVar에 3개의 변수가 있어야 함');
            Assert.areEqual('v1.0', kContext.pathVar.get('version'), 'version이 설정되어야 함');
            Assert.areEqual('users', kContext.pathVar.get('resource'), 'resource가 설정되어야 함');
            Assert.areEqual('123', kContext.pathVar.get('id'), 'id가 설정되어야 함');
        }
    }

    /**
     * @description 빈 pathVar 테스트
     */
    @IsTest
    static void testEmptyPathVar() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When
            APIContext kContext = new APIContext.Builder()
                .pattern('/api/health')
                .build();

            // Then
            Assert.isNotNull(kContext.pathVar, 'pathVar는 null이 아니어야 함');
            Assert.areEqual(0, kContext.pathVar.size(), 'pathVar가 빈 Map이어야 함');
        }
    }

    /**
     * @description 다양한 HTTP 메서드 테스트
     */
    @IsTest
    static void testVariousHttpMethods() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 다양한 HTTP 메서드
            List<String> kMethods = new List<String>{'GET', 'POST', 'PUT', 'DELETE', 'PATCH'};

            // When & Then
            for (String kMethod : kMethods) {
                APIContext kContext = new APIContext.Builder()
                    .httpMethod(kMethod)
                    .build();

                Assert.areEqual(kMethod, kContext.httpMethod, kMethod + ' 메서드가 설정되어야 함');
            }
        }
    }

    /**
     * @description processor 설정 테스트
     */
    @IsTest
    static void testProcessorSetting() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DummyProcessor kProcessor = new DummyProcessor();

            // When
            APIContext kContext = new APIContext.Builder()
                .processor(kProcessor)
                .build();

            // Then
            Assert.isNotNull(kContext.processor, 'processor가 설정되어야 함');
            Assert.isTrue(kContext.processor instanceof DummyProcessor, 'DummyProcessor 타입이어야 함');
        }
    }

    /**
     * @description Builder 메서드 체이닝 테스트
     */
    @IsTest
    static void testBuilderMethodChaining() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DummyProcessor kProcessor = new DummyProcessor();
            Map<String, String> kPathVar = new Map<String, String>{'id' => '999'};

            // When - 모든 메서드를 체이닝으로 호출
            APIContext kContext = new APIContext.Builder()
                .pattern('/api/test/:id')
                .requestUrl('/api/test/999')
                .httpMethod('DELETE')
                .processor(kProcessor)
                .pathVar(kPathVar)
                .build();

            // Then - 모든 필드가 설정되어야 함
            Assert.areEqual('/api/test/:id', kContext.pattern, 'pattern이 설정되어야 함');
            Assert.areEqual('/api/test/999', kContext.requestUrl, 'requestUrl이 설정되어야 함');
            Assert.areEqual('DELETE', kContext.httpMethod, 'httpMethod가 설정되어야 함');
            Assert.isNotNull(kContext.processor, 'processor가 설정되어야 함');
            Assert.areEqual(1, kContext.pathVar.size(), 'pathVar에 1개의 변수가 있어야 함');
        }
    }

    /**
     * @description 최소 필드만 설정 테스트
     */
    @IsTest
    static void testMinimalFields() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When - 최소한의 필드만 설정
            APIContext kContext = new APIContext.Builder()
                .build();

            // Then
            Assert.isNull(kContext.pattern, 'pattern이 null이어야 함');
            Assert.isNull(kContext.requestUrl, 'requestUrl이 null이어야 함');
            Assert.isNull(kContext.httpMethod, 'httpMethod가 null이어야 함');
            Assert.isNull(kContext.processor, 'processor가 null이어야 함');
            Assert.isNotNull(kContext.pathVar, 'pathVar는 초기화되어야 함');
            Assert.areEqual(0, kContext.pathVar.size(), 'pathVar가 빈 Map이어야 함');
        }
    }

    /**
     * @description 복사 생성자 - null pathVar 처리 테스트
     */
    @IsTest
    static void testCopyConstructorWithNullPathVar() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - pathVar를 null로 설정한 원본 (Builder는 항상 빈 Map 초기화하므로 직접 테스트 불가)
            APIContext kOriginal = new APIContext.Builder()
                .pattern('/api/test')
                .build();

            // When - 복사 생성자 사용
            APIContext kCopy = new APIContext.Builder(kOriginal)
                .build();

            // Then
            Assert.isNotNull(kCopy.pathVar, 'pathVar가 초기화되어야 함');
            Assert.areEqual(0, kCopy.pathVar.size(), 'pathVar가 빈 Map이어야 함');
        }
    }

    /**
     * @description 속성 읽기 전용 테스트 (컴파일 타임에 확인)
     */
    @IsTest
    static void testImmutability() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            APIContext kContext = new APIContext.Builder()
                .pattern('/api/test')
                .httpMethod('GET')
                .build();

            // When & Then - 속성을 읽을 수 있어야 함
            String kPattern = kContext.pattern;
            String kMethod = kContext.httpMethod;
            Map<String, String> kPathVar = kContext.pathVar;

            Assert.areEqual('/api/test', kPattern, 'pattern을 읽을 수 있어야 함');
            Assert.areEqual('GET', kMethod, 'httpMethod를 읽을 수 있어야 함');
            Assert.isNotNull(kPathVar, 'pathVar를 읽을 수 있어야 함');

            // Note: private set이므로 다음과 같은 코드는 컴파일 에러 발생
            // kContext.pattern = 'new value';  // Compile error
        }
    }
}
