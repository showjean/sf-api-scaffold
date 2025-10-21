/**
 * @description 경로 매칭을 위한 PathFinder 클래스 (와일드카드 미지원)
 */
public class PathFinder {
    private String prevPath;
    private String originPath;

    /**
     * @description 생성자
     * @param aPrevPath 지나온 경로 (예: '/api/v1.0')
     * @param aOriginPath 원본 요청 경로 (예: '/api/v1.0/users/profile')
     */
    public PathFinder(String aPrevPath, String aOriginPath) {
        this.prevPath = this.normalizePath(aPrevPath);
        this.originPath = this.normalizePath(aOriginPath);
    }

    /**
     * @description 다음 경로가 유효한지 확인 (PrevPath + NextPath가 OriginPath의 앞부분과 일치)
     * @param aNextPath 다음 경로 (예: '/users/profile')
     * @return 유효하면 true, 아니면 false
     */
    public Boolean find(String aNextPath) {
        String kNormalizedNext = this.normalizePath(aNextPath);

        // PrevPath + NextPath 계산
        String kCombinedPath = this.combinePath(this.prevPath, kNormalizedNext);

        System.debug(LoggingLevel.INFO, 'PathFinder.find() - PrevPath: ' + this.prevPath +
                ', NextPath: ' + kNormalizedNext + ', Combined: ' + kCombinedPath +
                ', OriginPath: ' + this.originPath);

        // 결합된 경로가 OriginPath와 정확히 일치하거나, OriginPath의 앞부분과 일치하는지 확인
        if (kCombinedPath == this.originPath) {
            return true;
        }

        // OriginPath가 결합된 경로로 시작하는지 확인 (앞부분 일치)
        // 예: Combined='/api/v1.0/users', Origin='/api/v1.0/users/profile' -> true
        if (this.originPath.startsWith(kCombinedPath + '/')) {
            return true;
        }

        return false;
    }

    /**
     * @description 두 경로를 결합
     * @param aPath1 첫 번째 경로
     * @param aPath2 두 번째 경로
     * @return 결합된 경로
     */
    private String combinePath(String aPath1, String aPath2) {
        // 첫 번째 경로가 비어있으면 두 번째 경로 반환
        if (String.isBlank(aPath1) || aPath1 == '/') {
            return aPath2;
        }

        // 두 번째 경로가 비어있으면 첫 번째 경로 반환
        if (String.isBlank(aPath2) || aPath2 == '/') {
            return aPath1;
        }

        // 두 경로 결합 (중복 '/' 제거)
        if (aPath2.startsWith('/')) {
            return aPath1 + aPath2;
        }
        else {
            return aPath1 + '/' + aPath2;
        }
    }

    /**
     * @description 경로 정규화 - trailing slash 제거
     * @param aPath 원본 경로
     * @return 정규화된 경로
     */
    private String normalizePath(String aPath) {
        if (String.isBlank(aPath)) {
            return '/';
        }

        // trailing slash 제거 (루트 경로는 유지)
        if (aPath.length() > 1 && aPath.endsWith('/')) {
            return aPath.substring(0, aPath.length() - 1);
        }

        return aPath;
    }
}
