/**
 * @description PathFinder 단위 테스트
 */
@IsTest
private class PathFinder_ts {

    /**
     * @description 기본 경로 매칭 테스트
     */
    @IsTest
    static void testBasicPathMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('', '/users');

            // When & Then
            Assert.areEqual('/users', kFinder.matches('/users'), '전체 경로가 일치해야 함');
            Assert.isNull(kFinder.matches('/profile'), '다른 경로는 불일치');
        }
    }

    /**
     * @description 계층 구조 경로 매칭 테스트
     */
    @IsTest
    static void testHierarchicalPathMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - PrevPath: '/api/v1.0', OriginPath: '/api/v1.0/users/profile'
            PathFinder kFinder = new PathFinder('/api/v1.0', '/api/v1.0/users/profile');

            // When & Then - PrevPath + NextPath가 OriginPath의 앞부분과 일치하거나 정확히 일치
            Assert.areEqual('/api/v1.0/users/profile', kFinder.matches('/users/profile'), '/users/profile이 정확히 일치');
            Assert.areEqual('/api/v1.0/users', kFinder.matches('/users'), '/users는 앞부분 일치');
            Assert.isNull(kFinder.matches('/profile'), '/profile은 불일치');
        }
    }

    /**
     * @description 복잡한 계층 구조 테스트
     */
    @IsTest
    static void testComplexHierarchy() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - PrevPath: '/api/v1.0/users/123', OriginPath: '/api/v1.0/users/123/view'
            PathFinder kFinder = new PathFinder('/api/v1.0/users/123', '/api/v1.0/users/123/view');

            // When & Then
            Assert.areEqual('/api/v1.0/users/123/view', kFinder.matches('/view'), '/view가 일치해야 함');
            Assert.isNull(kFinder.matches('/edit'), '/edit는 불일치');
        }
    }

    /**
     * @description Trailing slash 정규화 테스트
     */
    @IsTest
    static void testTrailingSlashNormalization() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/users');

            // When & Then - trailing slash 있어도 동일하게 처리
            Assert.areEqual('/api/users', kFinder.matches('/users'), 'trailing slash 없는 경로 매칭');
            Assert.areEqual('/api/users', kFinder.matches('/users/'), 'trailing slash 있는 경로도 동일하게 매칭');
        }
    }

    /**
     * @description 루트 경로 테스트
     */
    @IsTest
    static void testRootPath() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder1 = new PathFinder('', '/');
            PathFinder kFinder2 = new PathFinder('/', '/users');

            // When & Then
            Assert.areEqual('/', kFinder1.matches('/'), '루트 경로 / 매칭');
            Assert.areEqual('/', kFinder1.matches(''), '빈 문자열도 루트 경로로 매칭');
            Assert.areEqual('/users', kFinder2.matches('/users'), '/users 매칭');
        }
    }

    /**
     * @description PrevPath가 비어있는 경우 테스트
     */
    @IsTest
    static void testEmptyPrevPath() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - PrevPath가 비어있음
            PathFinder kFinder = new PathFinder('', '/api/users/profile');

            // When & Then
            Assert.areEqual('/api/users/profile', kFinder.matches('/api/users/profile'), '전체 경로가 정확히 일치');
            Assert.areEqual('/api/users', kFinder.matches('/api/users'), '부분 경로는 앞부분 일치');
            Assert.areEqual('/api', kFinder.matches('/api'), '더 짧은 부분 경로도 앞부분 일치');
        }
    }

    /**
     * @description NextPath에 슬래시가 없는 경우 테스트
     */
    @IsTest
    static void testNextPathWithoutSlash() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/users');

            // When & Then - NextPath에 슬래시가 없어도 자동으로 추가됨
            Assert.areEqual('/api/users', kFinder.matches('users'), 'users (슬래시 없음)');
            Assert.areEqual('/api/users', kFinder.matches('/users'), '/users (슬래시 있음)');
        }
    }

    /**
     * @description 다단계 경로 조합 테스트
     */
    @IsTest
    static void testMultiLevelPathCombination() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api/v1.0/users', '/api/v1.0/users/123/profile/edit');

            // When & Then
            Assert.areEqual('/api/v1.0/users/123/profile/edit', kFinder.matches('/123/profile/edit'), '다단계 경로 정확히 매칭');
            Assert.areEqual('/api/v1.0/users/123/profile', kFinder.matches('/123/profile'), '부분 경로는 앞부분 일치');
            Assert.areEqual('/api/v1.0/users/123', kFinder.matches('/123'), '더 짧은 부분 경로도 앞부분 일치');
            Assert.isNull(kFinder.matches('/profile/edit'), '시작 부분이 다르면 불일치');
        }
    }

    /**
     * @description 경로 정규화 일관성 테스트
     */
    @IsTest
    static void testPathNormalizationConsistency() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 모든 경로에 trailing slash
            PathFinder kFinder = new PathFinder('/api/', '/api/users/');

            // When & Then - trailing slash가 제거되고 비교됨
            Assert.areEqual('/api/users', kFinder.matches('/users'), 'trailing slash 자동 제거');
            Assert.areEqual('/api/users', kFinder.matches('/users/'), 'trailing slash 있어도 동일');
        }
    }

    /**
     * @description 불일치 케이스 테스트
     */
    @IsTest
    static void testMismatchCases() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api/v1.0', '/api/v1.0/users/profile');

            // When & Then - 여러 케이스
            Assert.areEqual('/api/v1.0/users', kFinder.matches('/users'), '부분 경로는 앞부분 일치');
            Assert.areEqual('/api/v1.0', kFinder.matches(''), '빈 경로는 루트 경로로 앞부분 일치');
            Assert.isNull(kFinder.matches('/users/profile/extra'), '더 긴 경로 불일치');
            Assert.isNull(kFinder.matches('/orders/profile'), '완전히 다른 경로 불일치');
        }
    }

    /**
     * @description 앞부분 일치 테스트
     */
    @IsTest
    static void testPrefixMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - OriginPath가 더 긴 경로
            PathFinder kFinder = new PathFinder('/api', '/api/v1.0/users/123/profile/settings');

            // When & Then - 점진적으로 경로를 늘려가며 앞부분 일치 확인
            Assert.areEqual('/api/v1.0', kFinder.matches('/v1.0'), '앞부분 일치 - v1.0');
            Assert.areEqual('/api/v1.0/users', kFinder.matches('/v1.0/users'), '앞부분 일치 - v1.0/users');
            Assert.areEqual('/api/v1.0/users/123', kFinder.matches('/v1.0/users/123'), '앞부분 일치 - v1.0/users/123');
            Assert.areEqual('/api/v1.0/users/123/profile', kFinder.matches('/v1.0/users/123/profile'), '앞부분 일치 - v1.0/users/123/profile');
            Assert.areEqual('/api/v1.0/users/123/profile/settings', kFinder.matches('/v1.0/users/123/profile/settings'), '정확히 일치');

            // 더 긴 경로는 불일치
            Assert.isNull(kFinder.matches('/v1.0/users/123/profile/settings/extra'), '더 긴 경로는 불일치');
        }
    }

    /**
     * @description 경계 조건 테스트 - 슬래시 경계 확인
     */
    @IsTest
    static void testBoundaryConditions() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/users123');

            // When & Then - '/api/users'는 '/api/users123'의 앞부분이 아님 (슬래시 경계 때문에)
            Assert.isNull(kFinder.matches('/users'), '/users는 /users123의 앞부분이 아님');
            Assert.areEqual('/api/users123', kFinder.matches('/users123'), '/users123는 정확히 일치');
        }
    }

    /**
     * @description 끝 와일드카드 매칭 테스트
     */
    @IsTest
    static void testTrailingWildcard() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/v1.0/users/123');

            // When & Then - 끝 와일드카드는 매칭된 부분까지만 반환
            Assert.areEqual('/api/v1.0/users', kFinder.matches('/v1.0/*'), '/v1.0/* 는 와일드카드 위치까지 반환');
            Assert.areEqual('/api/v1.0/users/123', kFinder.matches('/v1.0/users/*'), '/v1.0/users/* 는 와일드카드 위치까지 반환');
            Assert.isNull(kFinder.matches('/v2.0/*'), '/v2.0/* 는 /v1.0/users/123 와 불일치');
        }
    }

    /**
     * @description 끝 와일드카드 다중 세그먼트 매칭 테스트
     */
    @IsTest
    static void testTrailingWildcardMultipleSegments() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/users/123/profile/settings');

            // When & Then - 끝 와일드카드는 와일드카드 위치까지만 반환
            Assert.areEqual('/api/users/123', kFinder.matches('/users/*'), '/users/* 는 와일드카드 위치까지 반환');
            Assert.areEqual('/api/users/123/profile', kFinder.matches('/users/123/*'), '/users/123/* 도 와일드카드 위치까지 반환');
            Assert.areEqual('/api/users/123/profile/settings', kFinder.matches('/users/123/profile/*'), '/users/123/profile/* 도 와일드카드 위치까지 반환');
        }
    }

    /**
     * @description 중간 와일드카드 매칭 테스트
     */
    @IsTest
    static void testMiddleWildcard() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/v1.0/health');

            // When & Then - 중간 와일드카드는 정확히 한 세그먼트와 매칭
            Assert.areEqual('/api/v1.0/health', kFinder.matches('/*/health'), '/* /health 는 /v1.0/health 와 매칭');
            Assert.areEqual('/api/v1.0/health', kFinder.matches('/v1.0/health'), '/v1.0/health 정확한 매칭도 작동');
        }
    }

    /**
     * @description 중간 와일드카드 세그먼트 개수 불일치 테스트
     */
    @IsTest
    static void testMiddleWildcardSegmentMismatch() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/v1.0/users/view');

            // When & Then - 중간 와일드카드는 세그먼트 개수가 정확히 일치해야 함
            Assert.areEqual('/api/v1.0/users/view', kFinder.matches('/*/users/view'), '세그먼트 개수 일치');
            Assert.areEqual('/api/v1.0/users/view', kFinder.matches('/v1.0/*/view'), '다른 위치 와일드카드도 매칭');
            Assert.isNull(kFinder.matches('/*/view'), '세그먼트 개수 부족');
            Assert.isNull(kFinder.matches('/*/users/view/extra'), '세그먼트 개수 초과');
        }
    }

    /**
     * @description 여러 와일드카드 조합 테스트
     */
    @IsTest
    static void testMultipleWildcards() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/v1.0/users/123/view');

            // When & Then - 여러 와일드카드 조합
            Assert.areEqual('/api/v1.0/users/123/view', kFinder.matches('/*/users/*/view'), '두 개의 중간 와일드카드');
            Assert.areEqual('/api/v1.0/users/123/view', kFinder.matches('/v1.0/*/123/view'), '한 개의 중간 와일드카드');
            Assert.areEqual('/api/v1.0/users/123/view', kFinder.matches('/*/*/*/*'), '끝 와일드카드 - 패턴 길이만큼 반환');
        }
    }

    /**
     * @description 끝 와일드카드 vs 중간 와일드카드 구분 테스트
     */
    @IsTest
    static void testTrailingVsMiddleWildcard() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder1 = new PathFinder('/api', '/api/users/123/detail/info');
            PathFinder kFinder2 = new PathFinder('/api', '/api/orders/456/view');

            // When & Then - 끝 와일드카드는 와일드카드 위치까지만 반환
            Assert.areEqual('/api/users/123', kFinder1.matches('/users/*'), '끝 와일드카드 - 와일드카드 위치까지');
            Assert.areEqual('/api/users/123/detail', kFinder1.matches('/users/123/*'), '끝 와일드카드 - 와일드카드 위치까지');

            // When & Then - 중간 와일드카드는 정확한 개수만 매칭
            Assert.areEqual('/api/orders/456/view', kFinder2.matches('/orders/*/view'), '중간 와일드카드 - 정확히 매칭');
            Assert.areEqual('/api/orders/456', kFinder2.matches('/orders/*'), '끝 와일드카드 - 와일드카드 위치까지');
        }
    }

    /**
     * @description 와일드카드 + 앞부분 일치 조합 테스트
     */
    @IsTest
    static void testWildcardWithPrefixMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/v1.0/users/123/profile/edit');

            // When & Then - 끝 와일드카드는 와일드카드 위치까지만 반환
            Assert.areEqual('/api/v1.0/users', kFinder.matches('/v1.0/*'), '끝 와일드카드 - 와일드카드 위치까지');
            Assert.areEqual('/api/v1.0/users/123', kFinder.matches('/v1.0/users/*'), '끝 와일드카드 - 와일드카드 위치까지');
            Assert.areEqual('/api/v1.0/users/123/profile', kFinder.matches('/*/users/123/*'), '조합된 와일드카드 - 와일드카드 위치까지');
        }
    }
}
