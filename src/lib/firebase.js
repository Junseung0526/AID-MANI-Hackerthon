import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Firebase 설정 (실제 프로젝트에서는 환경 변수로 관리하세요)
const firebaseConfig = {
  apiKey: "AIzaSyAkMeCZa5XxlwHYAJ6hpYLMtEkUFIL9vrs",
  authDomain: "ai-hackerthon-codeblue.firebaseapp.com",
  projectId: "ai-hackerthon-codeblue",
  storageBucket: "ai-hackerthon-codeblue.firebasestorage.app",
  messagingSenderId: "1016643189915",
  appId: "1:1016643189915:web:92027bee120c53fb581a3e"
};

// Firebase 초기화
const app = initializeApp(firebaseConfig);

// Firestore 인스턴스
export const db = getFirestore(app);

// Storage 인스턴스
export const storage = getStorage(app);
