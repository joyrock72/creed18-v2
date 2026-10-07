# HTML 즉시 배포기

GitHub Pages를 이용해 HTML 문서를 공개 URL로 배포합니다. 기본값은 **공개(public) 저장소와 공개 웹사이트**입니다. 비밀번호·개인정보·비공개 문서는 넣지 마세요.

## 최초 1회

1. GitHub 계정이 없으면 `https://github.com/signup`에서 가입합니다.
2. 이 폴더에서 다음을 실행하고 브라우저 로그인과 권한 승인을 마칩니다.

```bash
./connect-github.sh
```

## HTML 문서 배포

```bash
./share-html.sh /경로/문서.html
```

처음 실행할 때 저장소 이름을 지정할 수도 있습니다.

```bash
./share-html.sh /경로/문서.html my-document
```

배포가 끝나면 터미널에 GitHub Pages URL이 표시됩니다. 이후 같은 명령을 실행하면 내용이 갱신됩니다.

## 직접 수정

`site/index.html`을 직접 편집한 경우에는 다음을 실행합니다.

```bash
./deploy.sh my-document
```

정적 파일(CSS, JS, 이미지)은 `site/` 안에 함께 넣으세요. HTML에서 참조하는 상대 경로도 유지됩니다.
