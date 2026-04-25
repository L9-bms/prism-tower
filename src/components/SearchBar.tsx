import type { TargetedEvent } from "preact";
import { FluentSearch24Regular } from "./icons/FluentSearch24Regular";

interface Props {
    searchUrl?: string;
}

export default function SearchBar({ searchUrl }: Props) {
    const handleSubmit = (e: TargetedEvent<HTMLFormElement>) => {
        e.preventDefault();

        const formData = new FormData(e.currentTarget);
        const query = formData.get("query")?.toString().trim();

        if (!query) return;

        const url = new URL(searchUrl ?? "https://google.com/search");
        url.searchParams.set("q", query);
        window.location.href = url.toString();
    };

    return (
        <div class="w-full max-w-2xl">
            <form class="relative" onSubmit={handleSubmit}>
                <input
                    type="text"
                    name="query"
                    placeholder="Search..."
                    autofocus
                    class="w-full px-6 py-3 rounded-full focus:outline-none frosted-glass"
                />
                <button
                    type="submit"
                    aria-label="Search"
                    class="absolute top-1/2 transform -translate-y-1/2 right-4 focus:outline-none hover:cursor-pointer"
                >
                    <FluentSearch24Regular />
                </button>
            </form>
        </div>
    );
}
