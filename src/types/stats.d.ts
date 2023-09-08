declare module 'stats-js' {
  export default function Stats(): {
    setMode: (mode: number) => void;
    domElement: HTMLElement;
    begin: () => void;
    end: () => void;
  };
}
