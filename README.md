# Fan Certification iOS
### (will be changed to English)
# 개요

유튜버, 인스타 인플루언서, 기타 여러 셀럽들의 팬을 인증할 수 있는 어플리케이션이다. 언제부터 셀럽의 팬이었는지를 초기 설정 날짜 등을 통해, 셀럽을 얼마나 좋아하는지를 좋아요 숫자 등으로 나타내어 인증할 수 있도록 하였다. 본 ReadMe에서는 iOS에 대해서만 다루겠다.

1. Firebase Firestore

로그인과 더불어 가장 중요한 간단한 NoSQL 데이터베이스 서비스이다. 구조는 아래와 같다.

- Users (Collection)
    - 앞서 Firebase Auth의 사용자 고유 UID (Document)
        - celeb (array, map 데이터 3개 저장, Nullable) - array 개수는 3개로 제한. 추후 인앱결재 등을 통해 늘일 수 있음.
            - account (string)
                
                YouTube의 경우 채널 ID, Instagram의 경우 username
                
            - count (number)
                
                좋아요를 누른 횟수
                
            - platform (number)
                
                YouTube는 0, Instagram은 1, ...
                
            - recent (datetime)
                
                최근 좋아요 등을 누른 날짜와 시간, (좋아요 + 1)을 시도할 때 이 날짜가 현재 시간 대비 10분 이내이면 리젝한다.
                
            - since (datetime)
                
                셀럽의 팬으로 처음 등록한 날짜와 시간
                
            - title (datetime)
                
                채널명
                
            - url (datetime)
                
                채널 url
                
- YouTube (Collection, 랭킹 등의 기능을 위해 필요)
    - YouTube Channel ID (Document)
        - follow (number)
            
            본 서비스 내 팔로워 수 (아주 정확하진 않아도 됨)
            
        - count (number)
            
            본 서비스 내 좋아요 수 (아주 정확하진 않아도 됨)
            
- Instagram (Collection, 랭킹 등의 기능을 위해 필요)
    - Instagram username (Document)
        - follow (number)
            
            본 서비스 내 팔로워 수 (아주 정확하진 않아도 됨)
            
        - count (number)
            
            본 서비스 내 좋아요 수 (아주 정확하진 않아도 됨)
            

2. Firebase Functions

현재 셉럽의 하트 추가, 셀럽의 추가/수정/삭제 등의 과정은 본 서비스에서 매우 중요한 과정이기 때문에, 클라이언트가 임의로 처리하는 게 아니라, 

3. 유튜브

유튜브 채널은 고유의 채널 ID가 있다. 그리고 이 ID를 검색하는 API는 아래와 같다. GET 방식이다.

https://www.googleapis.com/youtube/v3/search?part=id,snippet&type=channel&q={채널명 or 채널ID}&key={개인APIKEY}

출력되는 json 파일 구조 중 일부는 아래와 같다. 다만 변동될 수도 있으니 직접 테스트해보는 걸 추천

- items (array)
    - snippet
        - thumbnails
            - default
                - url (string, 채널 프로필사진 url)
        - channelTitle (string)
            
            채널명
            
        - channelId (string)
            
            채널 ID: 검색 후 셀럽을 등록할 땐 이 채널 ID를 사용하도록 한다.
            

4. 인스타그램 (준비 중)

인스타그램에는 고유의 사용자 ID와 있다. 하지만 현재는 공식적으로 모든 사용자의 ID를 검색할 수 있도록 하는 API는 없다. 그래서 임시로 username(고유 사용자 이름)을 사용하기로 한다. 인스타그램의 경우는 검색 기능을 보류한다. (혹시라도 고유 사용자 ID를 검색하는 API가 있다면 공유 부탁...)

# 화면 구성

[https://www.figma.com/file/O3Ig4q5gCj2FQJ292mcdCO/Fan-Certification?node-id=0%3A1](https://www.figma.com/file/O3Ig4q5gCj2FQJ292mcdCO/Fan-Certification?node-id=0%3A1)
