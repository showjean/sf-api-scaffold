/**
 * @description 경로 매칭을 위한 PathFinder 클래스
 */
public class PathFinder {
    private String prevPath;
    private String originPath;

    /**
     * @description 생성자
     * @param aPrevPath 지나온 경로
     * @param aOriginPath 원본 요청 경로
     */
    public PathFinder(String aPrevPath, String aOriginPath) {
        this.prevPath = this.normalizePath(aPrevPath);
        this.originPath = this.normalizePath(aOriginPath);
    }

    /**
     * @description 다음 경로가 유효한지 확인하고 일치하는 부분의 경로를 반환
     * @param aNextPath 다음 경로
     * @return 일치하는 경로 문자열, 일치하지 않으면 null
     */
    public String matches(String aNextPath) {
        String kNormalizedNext = this.normalizePath(aNextPath);
        String kCombinedPath = this.combine(this.prevPath, kNormalizedNext);

        System.debug(LoggingLevel.DEBUG, 'PathFinder.matches() - Combined: ' + kCombinedPath + ', Origin: ' + this.originPath);

        // 와일드카드 패턴 매칭
        if (kCombinedPath.contains('*')) {
            return this.matchWildcard(kCombinedPath, this.originPath);
        }

        // 정확히 일치
        if (kCombinedPath == this.originPath) {
            return this.originPath;
        }

        // 앞부분 일치
        if (this.originPath.startsWith(kCombinedPath + '/')) {
            return kCombinedPath;
        }

        return null;
    }

    /**
     * @description 두 경로를 결합
     * @param aPath1 첫 번째 경로
     * @param aPath2 두 번째 경로
     * @return 결합된 경로
     */
    public String combine(String aPath1, String aPath2) {
        if (String.isBlank(aPath1) || aPath1 == '/') {
            return aPath2;
        }

        if (String.isBlank(aPath2) || aPath2 == '/') {
            return aPath1;
        }

        if (aPath2.startsWith('/')) {
            return aPath1 + aPath2;
        }
        else {
            return aPath1 + '/' + aPath2;
        }
    }

    /**
     * @description 경로 정규화
     * @param aPath 원본 경로
     * @return 정규화된 경로
     */
    private String normalizePath(String aPath) {
        if (String.isBlank(aPath)) {
            return '/';
        }

        if (aPath.length() > 1 && aPath.endsWith('/')) {
            return aPath.substring(0, aPath.length() - 1);
        }

        return aPath;
    }

    /**
     * @description 와일드카드 패턴 매칭
     * @param aPattern 와일드카드가 포함된 패턴 경로
     * @param aPath 매칭할 실제 경로
     * @return 매칭되면 경로 문자열, 아니면 null
     */
    private String matchWildcard(String aPattern, String aPath) {
        List<String> kPatternSegments = this.splitPath(aPattern);
        List<String> kPathSegments = this.splitPath(aPath);

        Boolean kIsTrailingWildcard = !kPatternSegments.isEmpty() &&
                                       kPatternSegments[kPatternSegments.size() - 1].equals('*');

        if (kIsTrailingWildcard) {
            // 끝 와일드카드는 하나 이상의 세그먼트와 매칭
            if (kPatternSegments.size() - 1 > kPathSegments.size()) {
                return null;
            }

            for (Integer i = 0; i < kPatternSegments.size() - 1; i++) {
                if (i >= kPathSegments.size()) {
                    return null;
                }

                if (kPatternSegments[i].equals('*')) {
                    continue;
                }

                if (!kPatternSegments[i].equals(kPathSegments[i])) {
                    return null;
                }
            }

            // 와일드카드가 매칭한 부분까지 포함해서 반환
            Integer kMatchedCount = Math.min(kPatternSegments.size(), kPathSegments.size());
            List<String> kMatchedSegments = new List<String>();

            for (Integer i = 0; i < kMatchedCount; i++) {
                kMatchedSegments.add(kPathSegments[i]);
            }

            if (kMatchedSegments.isEmpty()) {
                return '/';
            }
            else {
                return '/' + String.join(kMatchedSegments, '/');
            }
        }
        else {
            // 중간 와일드카드는 정확한 세그먼트 개수 필요
            if (kPatternSegments.size() != kPathSegments.size()) {
                return null;
            }

            for (Integer i = 0; i < kPatternSegments.size(); i++) {
                if (kPatternSegments[i].equals('*')) {
                    continue;
                }

                if (!kPatternSegments[i].equals(kPathSegments[i])) {
                    return null;
                }
            }

            // 패턴 길이만큼만 반환
            List<String> kMatchedSegments = new List<String>();
            for (Integer i = 0; i < kPatternSegments.size(); i++) {
                kMatchedSegments.add(kPathSegments[i]);
            }

            if (kMatchedSegments.isEmpty()) {
                return '/';
            }
            else {
                return '/' + String.join(kMatchedSegments, '/');
            }
        }
    }

    /**
     * @description 경로를 세그먼트로 분할
     * @param aPath 분할할 경로
     * @return 세그먼트 리스트
     */
    private List<String> splitPath(String aPath) {
        List<String> kSegments = new List<String>();

        for (String kSeg : aPath.split('/')) {
            if (String.isNotBlank(kSeg)) {
                kSegments.add(kSeg);
            }
        }

        return kSegments;
    }
}
