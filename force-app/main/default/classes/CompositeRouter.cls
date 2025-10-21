/**
 * @description Composite 패턴의 Composite 역할 - 여러 하위 라우터/프로세서를 관리 (상대 경로 지원)
 */
public class CompositeRouter implements APIRouter {
    private String prefix;
    private List<RouteEntry> routes;

    /**
     * @description RouteEntry 내부 클래스 - 경로와 처리자를 매핑
     */
    private class RouteEntry {
        String pattern;
        Object handler; // APIRouter 또는 APIProcessor

        RouteEntry(String aPattern, Object aHandler) {
            this.pattern = aPattern;
            this.handler = aHandler;
        }

        /**
         * @description 경로 매칭 확인 (Apex는 와일드카드(*)만 지원)
         * @param aPath 요청 경로
         * @return 매칭 여부
         */
        Boolean matches(String aPath) {
            System.debug(LoggingLevel.INFO, this.handler.toString().substringBefore(':') +
                    ', matches() this:' + this.pattern + ', path:' + aPath);
            // 정확한 경로 매칭
            if (this.pattern == aPath) {
                return true;
            }

            // 와일드카드가 없는 경우
            if (!this.pattern.contains('*')) {
                return false;
            }

            // 끝에 와일드카드 (예: /api/v1.0/*) - 모든 하위 경로 매칭
            if (this.pattern.endsWith('/*')) {
                String kPrefix = this.pattern.substring(0, this.pattern.length() - 2);
                return aPath.startsWith(kPrefix);
            }

            // 중간에 와일드카드 (예: /api/v1.0/*/view) - 세그먼트별 매칭
            return this.matchesWithWildcard(aPath);
        }

        /**
         * @description 와일드카드를 포함한 패턴 매칭
         * @param aPath 요청 경로
         * @return 매칭 여부
         */
        private Boolean matchesWithWildcard(String aPath) {
            List<String> kPatternParts = this.pattern.split('/');
            List<String> kPathParts = aPath.split('/');

            // 세그먼트 개수가 다르면 매칭 실패
            if (kPatternParts.size() != kPathParts.size()) {
                return false;
            }

            // 각 세그먼트 비교
            for (Integer i = 0; i < kPatternParts.size(); i++) {
                String kPatternPart = kPatternParts[i];
                String kPathPart = kPathParts[i];

                // 와일드카드는 모든 값과 매칭
                if (kPatternPart == '*') {
                    continue;
                }

                // 정확히 일치해야 함
                if (kPatternPart != kPathPart) {
                    return false;
                }
            }

            return true;
        }

        /**
         * @description 하위 Router에 전달할 prefix 추출
         * @return 패턴에서 추출한 prefix
         */
        String extractPrefix() {
            // 끝 와일드카드 패턴 (예: /api/v1.0/*)
            if (this.pattern.endsWith('/*')) {
                return this.pattern.substring(0, this.pattern.length() - 2);
            }
            // 정확한 경로
            return this.pattern;
        }

        /**
         * @description 경로에서 패턴의 prefix를 제거하여 상대 경로 반환
         * @param aPath 절대 경로
         * @return 상대 경로
         */
        String toRelativePath(String aPath) {
            String kPrefix = this.extractPrefix();

            if (aPath.startsWith(kPrefix)) {
                String kRelativePath = aPath.substring(kPrefix.length());
                // prefix 제거 후 빈 문자열이면 '/'로 변환
                if (String.isBlank(kRelativePath)) {
                    return '/';
                }
                // '/'로 시작하지 않으면 추가
                if (!kRelativePath.startsWith('/')) {
                    return '/' + kRelativePath;
                }
                return kRelativePath;
            }

            return aPath;
        }
    }

    /**
     * @description 기본 생성자 (하위 호환성)
     */
    public CompositeRouter() {
        this('');
    }

    /**
     * @description Prefix를 지정하는 생성자
     * @param aPrefix 이 라우터가 처리할 경로의 prefix (예: '/api/v1.0')
     */
    public CompositeRouter(String aPrefix) {
        this.prefix = aPrefix;
        this.routes = new List<RouteEntry>();
    }

    /**
     * @description 하위 Router 등록
     * @param aPattern 경로 패턴
     * @param aRouter APIRouter 구현체
     * @return CompositeRouter 인스턴스 (체이닝용)
     */
    public CompositeRouter addRouter(String aPattern, APIRouter aRouter) {
        this.routes.add(new RouteEntry(aPattern, aRouter));
        return this;
    }

    /**
     * @description Processor 등록 (Leaf)
     * @param aPattern 경로 패턴
     * @param aProcessor APIProcessor 구현체
     * @return CompositeRouter 인스턴스 (체이닝용)
     */
    public CompositeRouter addProcessor(String aPattern, APIProcessor aProcessor) {
        this.routes.add(new RouteEntry(aPattern, aProcessor));
        return this;
    }

    /**
     * @description APIRouter 인터페이스 구현 - 경로에 맞는 Processor 반환
     * @param aPath 요청 경로
     * @return 매칭된 APIProcessor
     */
    public APIProcessor route(String aPath) {
        // prefix 제거하여 상대 경로로 변환
        String kRelativePath = this.removePrefix(aPath);
        System.debug(LoggingLevel.INFO, 'Path: ' + aPath + ', Relative Path => ' + kRelativePath);

        for (RouteEntry kEntry : this.routes) {
            if (kEntry.matches(kRelativePath)) {
                // Composite인 경우 재귀적으로 route() 호출 (상대 경로 전달)
                if (kEntry.handler instanceof APIRouter) {
                    String kSubPath = kEntry.toRelativePath(kRelativePath);
                    return ((APIRouter)kEntry.handler).route(kSubPath);
                }
                // Leaf인 경우 Processor 직접 반환
                else if (kEntry.handler instanceof APIProcessor) {
                    return (APIProcessor)kEntry.handler;
                }
            }
        }
        return null;
    }

    /**
     * @description 경로에서 prefix 제거
     * @param aPath 절대 경로
     * @return prefix가 제거된 상대 경로
     */
    private String removePrefix(String aPath) {
        if (String.isBlank(this.prefix)) {
            return aPath;
        }

        if (aPath.startsWith(this.prefix)) {
            String kRelativePath = aPath.substring(this.prefix.length());
            // prefix 제거 후 빈 문자열이면 '/'로 변환
            if (String.isBlank(kRelativePath)) {
                return '/';
            }
            // '/'로 시작하지 않으면 추가
            if (!kRelativePath.startsWith('/')) {
                return '/' + kRelativePath;
            }
            return kRelativePath;
        }

        return aPath;
    }
}
