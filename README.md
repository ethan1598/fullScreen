# fullScreen

iOS용 웹 콘텐츠 뷰어 앱. 설정 파일에 등록된 사이트에 접속하여 콘텐츠를 감상할 수 있으며, 내장 광고 차단 기능을 제공한다.

## 주요 기능

- 복수 사이트 바로가기
- 제목 검색
- JavaScript 기반 광고 차단 (MutationObserver를 활용한 실시간 광고 제거)
- 접속 URL 자동 저장 및 도메인 변경 감지
- 전체화면 웹뷰 (스크롤 시 네비게이션 바 자동 숨김)

## 기술 스택

| 항목 | 내용 |
|------|------|
| 언어 | Swift 5.0 |
| UI 프레임워크 | UIKit (Storyboard + 코드 혼합) |
| 웹 렌더링 | WKWebView |
| 로컬 DB | RealmSwift |
| 패키지 관리 | Swift Package Manager |
| 최소 지원 버전 | iOS 15.4+ |
| 지원 기기 | iPhone (세로 모드 전용) |

## 프로젝트 구조

```
fullScreen/
├── Resource/
│   ├── AppDelegate.swift          # 앱 라이프사이클
│   ├── SceneDelegate.swift        # 씬 관리
│   ├── Config.plist               # 사이트 URL 설정 (gitignore 대상)
│   ├── Config.example.plist       # 설정 파일 템플릿
│   ├── Info.plist                 # 앱 설정
│   └── StoryBoards/               # Main, LaunchScreen 스토리보드
├── Source/
│   ├── ViewController/
│   │   ├── ViewController.swift   # 메인 화면 (사이트 선택, 검색)
│   │   └── WebViewController.swift # 웹뷰 화면 (광고 차단, URL 감지)
│   └── Models/
│       └── UrlInfoRealm.swift     # Realm DB 모델
└── Assets.xcassets/               # 앱 아이콘 및 리소스
```

## 빌드 및 실행

1. Xcode 15.4 이상 설치
2. 프로젝트 클론
   ```bash
   git clone https://github.com/ethan1598/fullScreen.git
   ```
3. `Config.example.plist`를 복사하여 `Config.plist` 생성 후 실제 URL 입력
   ```bash
   cp fullScreen/Resource/Config.example.plist fullScreen/Resource/Config.plist
   ```
4. `fullScreen.xcodeproj`를 Xcode에서 열기
5. SPM 의존성이 자동으로 resolve됨 (RealmSwift)
6. iPhone 시뮬레이터 또는 실기기에서 빌드 및 실행

## 광고 차단 방식

WKWebView의 `WKUserScript`를 통해 페이지 로드 시점에 JavaScript를 주입한다. 대상 요소(배너, 네비게이션 등)를 CSS 선택자로 제거하며, `MutationObserver`를 통해 동적으로 추가되는 광고도 실시간으로 처리한다.

## 데이터 저장

Realm 데이터베이스를 사용하여 각 사이트의 최근 접속 URL을 로컬에 저장한다. 도메인 변경이 감지되면 사용자에게 확인 후 새 URL로 업데이트한다.
