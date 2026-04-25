import { useEffect, useState } from "preact/hooks";

function formatNow(date: Date) {
    return {
        time: date.toLocaleTimeString("en-US", { hour12: false }),
        date: date.toLocaleDateString("en-US", { dateStyle: "full" }),
    };
}

export default function Clock() {
    const [now, setNow] = useState(() => formatNow(new Date()));

    useEffect(() => {
        setInterval(() => {
            setNow(formatNow(new Date()));
        }, 1000);
    }, []);

    return (
        <div class="text-center hidden md:block">
            <div class="text-6xl font-bold">{now.time}</div>
            <div class="text-2xl font">{now.date}</div>
        </div>
    );
}
